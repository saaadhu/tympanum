require 'rubygems'
require 'sinatra'
require './post.rb'
require 'haml'
require './user.rb'

enable :sessions

get '/' do
	@page_number = 0
	@posts = Post.find_recent_posts
	haml :index
end

get '/pages/:number' do
    @page_number = params[:number].to_i
	@posts = Post.find_posts(@page_number)
	haml :index
end

get '/rss' do
	@posts = Post.find_recent_posts
	haml :rss, :layout => false
end

get '/search' do
	@query = params[:query]
	@results = Post.search(@query)
	haml :searchresults
end

get '/authenticate' do
	haml :login_or_register
end

post '/authenticate' do
	@userid = params[:user]
	@password = params[:password]
	if User.is_valid(@userid, @password) then
		session[:user] = @userid
		redirect '/'		
	else
		redirect 'authenticate'
	end
end

get '/posts/new' do
	redirect '/authenticate' unless session[:user]

	haml :newpost
end

post '/posts/new' do
	redirect '/authenticate' unless session[:user]

	title = params[:title]
	url = params[:url]
	user = session[:user]

	post = Post.new(user, title, url, Time.now.to_i)
	post.save!
	redirect '/'	
end

post '/register' do
	user = User.new(params[:user], params[:password])
	user.save!
	session[:user] = user.id

	redirect '/'
end
