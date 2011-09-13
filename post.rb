require 'rubygems'
require './tympanumdb.rb'

class Post
	@posts_in_page = 20

	attr_accessor :author, :title, :url
	attr_accessor :posts_in_page

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
		url_parts = @url.split(/[\/\. \+\&\?\=]/)
		url_parts.shift(1) #Exclude http
		url_parts.reject! { |part| /^(com|net|www|org|biz|aspx|asp|php|html|in|info)$|^\d+$/ === part }

		title_parts = @title.split /[ -]/
		title_parts.reject! { |part| /^\d+$|^(in|or|and)$/ === part }

		keywords = title_parts + url_parts.reject(&:empty?)
		keywords.map! &:downcase
		keywords.uniq
	end

	def Post.find_recent_posts()
		find_posts(0)
	end

	def Post.find_posts(page_number)
		posts_bson = TympanumDB.posts.
			find().sort([[:timestamp, -1]]).skip(@posts_in_page * page_number).limit(@posts_in_page)
		create_posts posts_bson
	end

	def Post.search (query)
		keywords = query.split().map &:downcase
		posts_bson = TympanumDB.posts.
			find(
				{ :keywords => { :$all => keywords } }).
			sort([[:timestamp, -1]]).
			limit(20)
		create_posts posts_bson
	end

	def Post.create_posts(posts_bson)
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

