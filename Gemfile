source 'https://rubygems.org'

gem 'fastlane'
gem 'cocoapods'
# 0.16.0 breaks Ruby 2.3 (current OSX) compatibility.
gem 'graphql-client', '<=0.15.0'
gem 'git-remote-parser'

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
