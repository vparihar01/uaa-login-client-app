class User < ActiveRecord::Base
  acts_as_authentic do |c|
    c.login_field = 'username'

  end # block optional
  attr_accessible :crypted_password, :password_salt, :persistence_token, :title, :username ,:password ,:password_confirmation
  attr_accessor :email,:name
  attr_accessible :email,:name

  def email
    @email
  end

  def email=(email_value)
    @email= email_value
  end

  def name
    @name
  end

  def name=(name_value)
    @name= name_value
  end
end
