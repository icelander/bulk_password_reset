require 'httparty'
require 'uri'
require 'time'
require 'digest'

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
			if (config.key?('username') && config.key?('password'))
				token = get_auth_token(config['username'], config['password'])
			end
		end

		if token.nil?
			raise 'token not set, check for token or username and password'
		end
		
		@options[:headers]['Authorization'] = "Bearer #{token}"
		@options[:body] = nil
	end

	def url_valid?(url)
		url = URI.parse(url) rescue false
	end

	def get_auth_token(username, password)
		response = post_data({login_id: username, password: password}, 'users/login')
		
		return response.headers['token']
	end

	def send_password_reset(email)
		post_data({'email' => email}, 'users/password/reset/send')
	end

	def get_users(params)
		return get_url("users?#{URI.encode_www_form(params)}")
	end

	def post_data(payload, request_url)
		options = @options
		options[:body] = payload.to_json
		
		return self.class.post("#{@base_uri}#{request_url}", options)
	end

	def get_url(url)
		JSON.parse(self.class.get("#{@base_uri}#{url}", @options).to_s)
	end
end