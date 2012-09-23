require 'sinatra'
require 'haml'
require 'glorify'

get "/" do
  css :main_style
  if current_user
    @posts = current_user.posts.all(:order => [:id])
    p File.dirname(__FILE__)
    @output_arr = []
    @posts.each do |post|  
      @output = File.open("#{post.file_src}", "rb").read
      @output.force_encoding("UTF-8")
      @output_arr << @output
    end  
  end
  haml :index
end

get '/signup' do
  haml :signup
end

post '/signup' do
  user = User.create(params[:user])
  user.password_salt = BCrypt::Engine.generate_salt
  user.password_hash = BCrypt::Engine.hash_secret(params[:user][:password], user.password_salt)
  if user.save
    flash[:info] = "Thank you for registering #{user.email}"
    session[:user] = user.token
    redirect "/"
  else
    session[:errors] = user.errors.full_messages
    redirect "/signup?" + hash_to_query_string(params[:user])
  end
end

get '/login' do
  if current_user
    redirect_last
  else
    haml :login
  end
end

post '/login' do
  user = User.first(:email => params[:email])
  if user
    if user.password_hash == BCrypt::Engine.hash_secret(params[:password], user.password_salt)
      session[:user] = user.token
      if params[:remember_me]
        response.set_cookie "user", {:value => user.token, :expires => (Time.now + 52*7*24*60*60)}
      end
      redirect_last
    else
      flash[:error] = "Email/Password combination does not match"
      redirect "/login?email=#{params[:email]}"
    end
  else
    flash[:error] = "That email address is not recognised"
    redirect "/login?email=#{params[:email]}"
  end
end

get '/logout' do
  current_user.generate_token
  response.delete_cookie "user"
  session[:user] = nil
  flash[:info] = "Successfully logged out"
  redirect '/'
end

get '/admin/post/:id' do 
  css :admin_style
  js :ace, :admin
  @post = current_user.posts.get(params[:id])
  @output = File.open("#{@post.file_src}", "rb").read
  @output.force_encoding("UTF-8")

  if current_user
    haml :admin_post
  else 
    redirect "/"
  end
end