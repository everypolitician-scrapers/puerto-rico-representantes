# frozen_string_literal: true

require 'rubocop/rake_task'
require 'rake/testtask'

RuboCop::RakeTask.new

Rake::TestTask.new do |t|
  t.test_files = FileList['test/**/*_test.rb']
end

require 'scraper_test'
ScraperTest::RakeTask.new.install_tasks

task test: 'test:data'
task default: %w[rubocop test]
