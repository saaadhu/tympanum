require 'rubygems'
require './tympanumdb.rb'

class Post
	attr_accessor :author, :title, :url

	def initialize(author, title, url, timestamp)
		@author, @title, @url = author, title, url
		@timestamp = timestamp
	end

	def get_time_since_post
		diff_seconds = Time.now.to_i - @timestamp

		m, s = diff_seconds.divmod(60)
		return "#{s} second#{'s' if s > 1} ago" if m == 0

		h, m = m.divmod(60)
		return "#{m} minute#{'s' if m > 1} ago" if h == 0

		d, h = h.divmod(24)
		return "#{h} hour#{'s' if h > 1} ago" if d == 0

		return "#{d} day#{'s' if d > 1} ago"

	end

	def save!
		keywords = find_keywords
		obj = { 
			:author => @author, 
			:title => @title, 
			:url => @url, 
			:timestamp => @timestamp,
			:keywords => keywords
			}
		TympanumDB.posts.insert(obj)
	end

	def find_keywords
		url_parts = @url.split(/[\/\. -]/)
		url_parts.shift(1) #Exclude http
		url_parts.reject! { |part| /com|net|www|org|biz|in|info/ === part }

		title_parts = @title.split /[ -]/
		title_parts.reject! { |part| /^\d+$/ === part }

		title_parts + url_parts.reject(&:empty?)
	end

	def Post.find_recent_posts()
		posts_bson = TympanumDB.posts.
			find().sort([[:timestamp, -1]]).limit(20)

		posts = []
		posts_bson.each do |post_bson| 
			post = Post.new(
				post_bson["author"], 
				post_bson["title"],
				post_bson["url"], 
				post_bson["timestamp"])
				
			posts << post
		end

		posts
	end
end

