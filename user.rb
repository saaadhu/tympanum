require 'rubygems'
require 'tympanumdb'

class User
	attr_accessor :id, :password

	def User.is_valid(id, pwd)
		res = TympanumDB.users.find_one({:id => id, :password => pwd})
		res.nil? == false
	end

	def initialize(id, pwd)
		@id = id
		@pwd = pwd
	end

	def save!
		TympanumDB.users.insert({:id => @id, :password => @pwd})
	end
end
