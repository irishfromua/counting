require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/activerecord'
require './helpers/helper.rb'
require 'bcrypt'
require 'pry'

set :bind, '0.0.0.0'

set :database, "sqlite3:counting.db"

enable :sessions

after { ActiveRecord::Base.connection.close }

class User < ActiveRecord::Base
  validates_presence_of :username 
  validates_format_of :email, :with => /@/
  validates_presence_of :password
  validates_confirmation_of :username, :password
  validates_confirmation_of :email
end

class Thing < ActiveRecord::Base
end

get '/' do
  @counters = User.count
  @things = Thing.count
  erb :index
end

# get login
get '/sessions/new' do
  erb :"sessions/new"
end

# post login
post '/sessions' do
  user = User.find_by(email: params[:user][:email])
  if user && user.password == BCrypt::Engine.hash_secret(params[:user][:password], user.salt)
    session[:id] = user.id
    redirect "/users/#{user.id}"
  else
    @error = "Email or Password is incorrect."
    erb :"/sessions/new"
  end
end

# get sign up
get '/users/new' do
  @user = User.new
  erb :"users/new"
end

# post sign up
post '/users' do
  exist_user = User.find_by(email: params[:user][:email])
  if exist_user != nil
    erb :"users/new"
  else
    if params[:user][:password] == params[:user][:password_confirmation]
      
      password_salt = BCrypt::Engine.generate_salt
      password_hash = BCrypt::Engine.hash_secret(params[:user][:password], password_salt)

      user = User.create(username: params[:user][:username],
                         email:    params[:user][:email],
                         password: password_hash,
                         salt:     password_salt)
      
      if user.valid?
        user.save
        session[:id] = user.id
        redirect '/users/show'
      else
        @error = user.errors.full_messages
        erb :"users/new"
      end
    else
      erb :"users/new"
    end
  end
end

# get profile
get '/users/:id' do
  @user ||= User.find(session[:id])
  @user_things = Thing.where(user_id: @user.id)
  erb :"users/show"
end

# logout
delete '/sessions' do
  session.clear
  redirect '/'
end

get '/users/:id/things/new' do
#  current_user
  @user ||= User.find(session[:id])
  erb :"things/new"
end

post '/users/:id/things' do
  if params[:thing][:title] != ""
    t = Thing.new(user_id: params[:id], title: params[:thing][:title], count: 0)
    t.save
    @user ||= User.find(session[:id])
    @user_things = Thing.where(user_id: @user.id)
    erb :"users/show"
  else
    @user ||= User.find(session[:id])
    erb :"things/new"
  end
end

get '/users/:id/things/:thing_id/edit' do
  @user ||= User.find(session[:id])
  @edit_thing = Thing.find(params[:thing_id])
  erb :"things/edit"
end

put '/users/:id/things/:thing_id' do
  new_title = params[:edit_thing][:title]
  if new_title != ""
    t = Thing.find(params[:thing_id])
    t.update(:title => new_title)
    @user ||= User.find(session[:id])
    @user_things = Thing.where(user_id: @user.id)
    erb :"users/show"
  else
    @user ||= User.find(session[:id])
    @edit_thing = Thing.find(params[:thing_id])
    erb :"things/edit"
  end
end

delete '/users/:id/things/:thing_id' do 
  t = Thing.find(params[:thing_id])
  t.destroy
  @user ||= User.find(session[:id])
  @user_things = Thing.where(user_id: @user.id)
  erb :"users/show"
end

put '/users/:id/things/:thing_id/inc' do
  t = Thing.find(params[:thing_id])
  t.increment(:count)
  t.save
  redirect to('/users/show')
end

put '/users/:id/things/:thing_id/dec' do
  t = Thing.find(params[:thing_id])
  t.decrement(:count)
  t.save
  redirect to('/users/show')
end