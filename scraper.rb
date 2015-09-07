#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'colorize'
require 'pry'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class String
  def tidy
    self.gsub(/[[:space:]]+/, ' ').strip
  end
end

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape_list(url)
  noko = noko_for(url)
  noko.css('div.info-block div.info-wrap').each do |person|
    data = { 
      id: person.css('a.more-info/@href').text[/rep=(\d+)/, 1],
      name: person.xpath('.//span[@class="info"]//span[@class="name"]/text()').text.split(' - ').first.tidy.sub('Hon. ', ''),
      party: person.css('.info .party').text.tidy,
      area: person.css('.info .district').text.tidy,
      image: person.css('.identity img/@src').text,
      phone: person.xpath('.//span[@class="data-type" and contains(.,"Tel:")]').map { |n| n.text.sub('Tel:','').tidy }.join(" / "),
      fax: person.xpath('.//span[@class="data-type" and contains(.,"Fax:")]').map { |n| n.text.sub('Fax:','').tidy }.join(" / "),
      contact_form: person.css('a.mail/@href').text,
      term: 29,
      source: person.css('a.more-info/@href').text,
    }
    %i(image contact_form source).each { |field| data[field] = URI.join(url, data[field]).to_s unless data[field].to_s.empty? }
    ScraperWiki.save_sqlite([:id, :term], data)
  end
end

scrape_list('http://www.tucamarapr.org/dnncamara/web/composiciondelacamara.aspx')
