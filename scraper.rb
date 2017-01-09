#!/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

require 'pry'
require 'scraped'
require 'scraperwiki'

# require 'open-uri/cached'
# OpenURI::Cache.cache_path = '.cache'
require 'scraped_page_archive/open-uri'

class MemberDiv < Scraped::HTML
  field :id do
    noko.css('a.more-info/@href').text[/rep=(\d+)/, 1]
  end

  field :name do
    noko.xpath('.//span[@class="info"]//span[@class="name"]/text()').text.split(' - ').first.tidy.sub('Hon. ', '')
  end

  field :party do
    noko.css('.info .party').text.tidy
  end

  field :area do
    noko.css('.info .district').text.tidy
  end

  field :image do
    noko.css('.identity img/@src').text
  end

  field :phone do
    noko.xpath('.//span[@class="data-type" and contains(.,"Tel:")]').map { |n| n.text.sub('Tel:', '').tidy }.reject(&:empty?).join(' / ')
  end

  field :fax do
    noko.xpath('.//span[@class="data-type" and contains(.,"Fax:")]').map { |n| n.text.sub('Fax:', '').tidy }.reject(&:empty?).join(' / ')
  end

  field :contact_form do
    noko.css('a.mail/@href').text
  end

  field :source do
    noko.css('a.more-info/@href').text
  end
end

class MembersPage < Scraped::HTML
  decorator Scraped::Response::Decorator::AbsoluteUrls

  field :members do
    noko.css('div.info-block div.info-wrap').map do |div|
      fragment div => MemberDiv
    end
  end
end

start = 'http://www.tucamarapr.org/dnncamara/web/composiciondelacamara.aspx'
page = MembersPage.new(response: Scraped::Request.new(url: start).response)
data = page.members.map(&:to_h)
# puts data

ScraperWiki.sqliteexecute('DELETE FROM data') rescue nil
ScraperWiki.save_sqlite(%i(id party area), data)

# visit each 'source' page to archive it
data.each { |p| open(p[:source]).read }
