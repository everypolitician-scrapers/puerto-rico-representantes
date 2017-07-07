# frozen_string_literal: true

require 'scraped'

class MemberPage < Scraped::HTML
  field :party do
    noko.at_css('.partyBio').text.tidy
  end

  field :phone do
    contact_numbers_for('Tel')
  end

  field :fax do
    contact_numbers_for('Fax')
  end

  field :tty do
    contact_numbers_for('TTY')
  end

  private

  def contact_numbers
    noko.xpath('.//span[@class="data-type"]')
  end

  def contact_numbers_for(str)
    contact_numbers.xpath("text()[contains(.,'#{str}')]").map do |n|
      n.text.gsub("#{str}.", '').tidy
    end.reject(&:empty?).join(';')
  end
end
