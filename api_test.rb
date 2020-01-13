#!/usr/bin/ruby

require './lib/mattermost_api.rb'

$config = YAML.load(
	File.open('conf.yaml').read
)

mm = MattermostApi.new($config['mattermost'])

puts mm.get_all_users