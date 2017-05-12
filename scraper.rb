#!/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

require 'pry'
require 'scraped'
require 'scraperwiki'

# require 'open-uri/cached'
# OpenURI::Cache.cache_path = '.cache'
require 'scraped_page_archive/open-uri'

require_rel 'lib'


class MembersPage < Scraped::HTML
  decorator Scraped::Response::Decorator::CleanUrls

  field :members do
    noko.css('.list-article .selectionRep').map do |div|
      fragment div => MemberDiv
    end
  end
end

start = 'http://www.tucamarapr.org/dnncamara/web/ComposiciondelaCamara/Biografia.aspx'
page = MembersPage.new(response: Scraped::Request.new(url: start).response)
data = page.members.map(&:to_h)
data.each { |mem| puts mem.reject { |_, v| v.to_s.empty? }.sort_by { |k, _| k }.to_h } if ENV['MORPH_DEBUG']

ScraperWiki.sqliteexecute('DROP TABLE data') rescue nil
ScraperWiki.save_sqlite(%i[id party area], data)

# visit each 'source' page to archive it
data.each { |p| open(p[:source]).read }
