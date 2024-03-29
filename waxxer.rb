#!/usr/bin/env ruby
# vim: noet sts=4:ts=4:sw=4
# author: takano32 <tak at no32.tk>
#

require 'rubygems'
require 'pit'
require 'oauth'
require 'rubytter'

require 'open-uri'
require 'nokogiri'
require 'cgi'

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
		text = @wax.status[:text]
		@rubytter.update(text) if text
		return text
	end
end

class Waxxer::Wax
	def status(id = nil)
		return {:text => nil}
	end
end


class Waxxer::TwilogWax < Waxxer::Wax
	def initialize(since = Date.new(2010, 1, 10))
		@since = since
	end

	def status(id = nil)
		statuses = []
		date = nil
		begin
			today = Date.today
			year = rand * (today.year - @since.year) + @since.year + 0.5
			month = rand * 12 + 1
			day = rand * 31 + 1
			date = Date.new(year.floor, month.floor, day.floor)
			raise if date < @since or today < date
		rescue Exception => e
			retry
		end

		uri = date.strftime('http://twilog.org/takano32/date-%y%m%d')
		doc = Nokogiri::HTML(open(uri))
		doc.css('p.tl-text').each do |nodeset|
			begin
				text = nodeset.children.map do |node|
					case node.name
					when 'a'
						raise
					else
						node.to_s
					end
				end.join('')
			rescue
				next
			end
			status = {}
			status[:text] = CGI.unescapeHTML(text)
			statuses << status
		end
		return status if statuses.empty?
		return statuses.shuffle.first
	end

end

class Waxxer::FavotterWax < Waxxer::Wax
	def initialize(threshold = 1, last = 501)
		@threshold = threshold
		@last = last
	end
	def status(id = nil)
		statuses = []
		page = (rand * @last).floor
		uri = "http://favotter.net/user/takano32?threshold=#{@threshold}&page=#{page}"
		doc = Nokogiri::HTML(open(uri))
		doc.css('span.status_text').each do |nodeset|
			begin
				text = nodeset.children.map do |node|
					case node.name
					when 'a'
						raise
					when 'span'
						if node.attributes['class'].to_s == 'censored' then
							'XXX'
						else
							node.to_s
						end
					else
						node.to_s
					end
				end.join('')
			rescue Exception => e
				next
			end
			status = {}
			status[:text] = CGI.unescapeHTML CGI.unescapeHTML(text)
			statuses << status
		end
		return status if statuses.empty?
		return statuses.shuffle.first
	end
end

if __FILE__ == $0 then
	wax = Waxxer::FavotterWax.new(2)
	# wax = Waxxer::TwilogWax.new
	waxxer = Waxxer.new(wax)
	puts waxxer.say
end

