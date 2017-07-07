# frozen_string_literal: true

require 'scraped'

class MemberDiv < Scraped::HTML
  field :id do
    source.split('=').last
  end

  field :name do
    bio.first.sub('Hon. ', '')
  end

  field :area do
    bio.last.split(/del|por/).last.tidy
  end

  field :image do
    noko.at_css('img @src').text
  end

  field :source do
    noko.at_css('a @href').text
  end

  private

  def bio
    noko.at_css('.biodiv').text.split("\n").map(&:tidy).reject(&:empty?)
  end
end
