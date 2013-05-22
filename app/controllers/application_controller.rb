class ApplicationController < ActionController::Base
  require 'yajl'
  require 'rest-client'

  protect_from_forgery
  helper_method :current_user_session, :current_user
  before_filter :check_token
  private

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.record
  end

  def check_token
    logger.info("Inspecting post_request_for_user_info   #{session.inspect} ########")
  end

end
