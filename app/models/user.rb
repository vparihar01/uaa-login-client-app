class User < ActiveRecord::Base
  acts_as_authentic do |c|
    c.login_field = 'username'

  end # block optional
  attr_accessible :crypted_password, :password_salt, :persistence_token, :title, :username ,:password ,:password_confirmation
end
