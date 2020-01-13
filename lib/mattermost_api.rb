require 'httparty'
require 'uri'
require 'time'
require 'digest'
require 'pp'

class MattermostApi
	include HTTParty

	format :json
	debug_output $stdout
	
	def initialize(config)
		# Default Options
		@options = {
			headers: {
				'Content-Type' => 'application/json',
				'User-Agent' => 'Mattermost-HTTParty'
			},
			# TODO Make this more secure
			verify: false
		}

		# check the config for mattermost_url
		if ! (config.key?("url") && url_valid?(config['url']))
			raise 'url is required in configuration'
		end

		@base_uri = config['url'] + 'api/v4/'

		token = nil

		if config.key?('auth_token')
			token = config['auth_token']
		else
			# Use password login
			if (config.key?('login_id') && config.key?('password'))
				token = get_login_token(config['login_id'], config['password'])
			end
		end

		if token.nil?
			raise 'token not set, check for token or login_id and password'
		end
		
		@options[:headers]['Authorization'] = "Bearer #{token}"
		@options[:body] = nil
	end

	def url_valid?(url)
		url = URI.parse(url) rescue false
	end

	def get_all_users
		page = 0
		num_returned = 0
		results = []

		loop do
			result = get_url('users?per_page=200') # max number of users per page
			num_returned = result.length
			results = results + result

			break if num_returned < 200
		end

		return results
	end

	def get_users(params)
		return get_url("users?#{URI.encode_www_form(params)}")
	end

	def post_data(payload, request_url)
		options = @options
		options[:body] = payload.to_json
		
		return self.class.post("#{@base_uri}#{request_url}", options)
	end

	def put_data(payload, request_url)
		options = @options
		options[:body] = payload.to_json

		self.class.put("#{@base_uri}#{request_url}", options)
	end

	def get_url(url)
		JSON.parse(self.class.get("#{@base_uri}#{url}", @options).to_s)
	end
end