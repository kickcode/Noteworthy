# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/osx'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

Dotenv.load

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'Noteworthy'
  app.identifier = "com.#{ENV['ORG']}.#{app.name.downcase}"
  app.entitlements["com.apple.developer.ubiquity-container-identifiers"] = ["iCloud.#{app.identifier}"]
  app.entitlements['com.apple.application-identifier'] = "#{ENV['TEAM_ID']}.#{app.identifier}"
  app.entitlements["com.apple.developer.ubiquity-kvstore-identifier"] = app.entitlements['com.apple.application-identifier']

  app.codesign_for_development = true
end
task :"build:development" => :"schema:build"
