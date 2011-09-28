#!/usr/bin/env ruby
# vim: noet sts=4:ts=4:sw=4
# author: takano32 <tak at no32.tk>
#

require 'rubygems'
require 'pit'
require 'oauth'
require 'rubytter'




class Waxxer
	def initialize(wax)
		@wax = wax
		config = Pit.get("twitter",
						 :require => {
			'consumer_key' => 'client CONSUMER_KEY',
			'consumer_secret' => 'client CONSUMER_SECRET',
			'access_token' => 'oauth ACCESS_TOKEN',
			'access_token_secret' => 'oauth ACCESS_TOKEN_SERCTET',
		})

		consumer = OAuth::Consumer.new(
			config['consumer_key'],
			config['consumer_secret'],
			:site => 'http://api.twitter.com'
		)

		access_token = OAuth::AccessToken.new(
			consumer,
			config['access_token'],
			config['access_token_secret']
		)
		@rubytter = OAuthRubytter.new(access_token)
	end

	def say
		status = @wax.status
	end
end

class Waxxer::Wax
	# status(id = rand)
end

class Waxxer::TwilogWax < Waxxer::Wax
end

class Waxxer::FavotterWax < Waxxer::Wax
end

if __FILE__ == $0 then
end

