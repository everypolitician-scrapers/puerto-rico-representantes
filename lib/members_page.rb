# frozen_string_literal: true

require 'scraped'
require_relative 'member_div'

class MembersPage < Scraped::HTML
  decorator Scraped::Response::Decorator::CleanUrls

  field :members do
    noko.css('.list-article .selectionRep').map do |div|
      fragment div => MemberDiv
    end
  end
end
