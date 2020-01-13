#!/usr/bin/env ruby

require 'json'
require 'securerandom'
require './lib/mattermost_api.rb'

$config = YAML.load(
    File.open('conf.yaml').read
)

def password_valid?(password, password_config)
    regex_tests = {
        'Lowercase' => /[a-z]/,
        'Uppercase' => /[A-Z]/,
        'Number' => /[0-9]/,
        'Symbol' => /[ !"#$%&'()*+,-.\/:;<=>?@\[\]^_`|~]/
    }

    if password.length < password_config['MinimumLength']
        puts "Password is too short"
        return false
    end

    if password_config['Uppercase'] && password.match(/[A-Z]/).nil?
        puts "Password does not contain uppercase"
        return false
    end

    if password_config['Lowercase'] && password.match(/[a-z]/).nil?
        puts "Password does not contain lowercase"
        return false
    end

    if password_config['Number'] && password.match(/[0-9]/).nil?
        puts "Password does not contain number"
        return false
    end

    if password_config['Symbol'] && password.match(/[ !"#$%&'()*+,-.\/:;<=>?@\[\]^_`|~]/).nil?
        puts "Password does not contain symbol"
        return false
    end

    return true
end

# How to use:
#
# 1. Place this file in your Mattermost server directory, usually `/opt/mattermost/scripts`, and run `/opt/mattermost/scripts/sudo chmod +x batch_password_reset.rb`
# 2. Put 
# 2. Generate an Authentication Token with administrator privileges and enter it here:
# 3. Generate a list of users with email authentication
# 4. (Optional) Modify `/opt/mattermost/templates/password_change_body.html` to customize the outgoing email
# 5. Run this script like this to dynamically generate new passwords: 
#
# 		sudo ./batch_password_reset.rb 
#
#    If you want all users to have the same password, add it as an argument:
#
# 		sudo ./batch_password_reset.rb 'P@sSw0rD'
#
# NOTE: The password provided must meet the configured password requirements

# Get the list of users

# Read config file

config_paths = ['./config.json', 
                '../config/config.json', 
                '../../config/config.json', 
                '/opt/mattermost/config/config.json']
config_path = nil

config_paths.each do |test_config_path|
	if File.file? test_config_path
		config_path = test_config_path
		break
	end
end

if config_path.nil?
	puts "Couldn't find configuration file. Please place this script in the directory /opt/mattermost"
	exit
end

# binary_paths = ['./mattermost', 
#                 '../bin/mattermost', 
#                 '../../bin/mattermost', 
#                 '/opt/mattermost/bin/mattermost']
# binary_path = nil

# binary_paths.each do |test_binary_path|
#     if File.file? test_binary_path
#         binary_path = test_binary_path
#         break
#     end
# end

# if binary_path.nil?
#     puts "Couldn't find Mattermost binary. Please place this script in the directory /opt/mattermost"
#     exit
# end

config_hash = JSON.parse(File.read(config_path))

mandatory_password = ARGV[0]

if !mandatory_password.nil? && !password_valid(mandatory_password, config['PasswordSettings'])
    puts "Provided password does not meet requirements. Exiting"
    exit
end

page = 0
per_page = 200
num_returned = 0


mm = MattermostApi.new($config['mattermost'])

loop do
    result = mm.get_users({page: page, per_page: per_page}) # max number of users per page

    pp result
    
    num_returned = result.length
    break if num_returned < per_page
    page = page + 1
end