require "data_mapper"
require "bcrypt"
require "securerandom"

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/development.db")

class User 
  include DataMapper::Resource
  
  attr_accessor :password, :password_confirmation

  property :id,             Serial
  property :email,          String,     :required => true, :unique => true, :format => :email_address
  property :password_hash,  Text  
  property :password_salt,  Text
  property :token,          String
  property :created_at,     DateTime
  property :admin,          Boolean,    :default => false
  
  validates_presence_of         :password
  validates_confirmation_of     :password
  validates_length_of           :password, :min => 6

  has n, :posts

  after :create do
    self.token = SecureRandom.hex
  end

  def generate_token
    self.update!(:token => SecureRandom.hex)
  end

  def admin?
    self.admin
  end

end

class Post
  include DataMapper::Resource

  property :id,             Serial
  property :name,           String,       :required => true
  property :file_src,       String,       :required => true
  property :created_at,     DateTime
  property :updated_at,     DateTime
  property :stat,           Integer,      :default => 0

  belongs_to :user

end

DataMapper.finalize
DataMapper.auto_upgrade!