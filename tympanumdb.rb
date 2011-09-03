require 'rubygems'
require 'mongo'

class TympanumDB

	def TympanumDB.db
		#@@db ||= Mongo::Connection.new("staff.mongohq.com", 10008).db("tympanum")
		@@db = Mongo::Connection.new.db("tympanum")
		#@auth || = @db.authenticate('saaadhu', 'genius') unless @auth
		@@db
	end

	def TympanumDB.posts
		db["posts"]
	end

	def TympanumDB.users
		db["users"]
	end
end
