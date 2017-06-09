# frozen_string_literal: true

require_relative './test_helper'
require_relative '../lib/members_page'

describe MembersPage do
  around { |test| VCR.use_cassette(File.basename(url), &test) }

  let(:yaml_data) { YAML.load_file(subject) }
  let(:url) { 'http://www.tucamarapr.org/dnncamara/web/ComposiciondelaCamara/Biografia.aspx' }
  let(:response) { MembersPage.new(response: Scraped::Request.new(url: url).response) }

  describe 'MemberDiv' do
    let(:subject) { './test/custom_test_data/member_div.yml' }

    it 'returns the expected data' do
      response.members.first.to_h.must_equal yaml_data
    end
  end
end
