class UserSessionsController < ApplicationController
  require 'rest-client'
  require 'uaa'

  # GET /user_sessions/new
  # GET /user_sessions/new.json
  def new
    @user_session = UserSession.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user_session }
    end
  end

  # POST /user_sessions
  # POST /user_sessions.json
  def create
    @user_session = UserSession.new(params[:user_session])
    #token_issuer = `uaac --debug token client get #{@user_session.username} --secret #{params[:user_session][:password]}`
    #logger.info "test post to authorize the request #{token_issuer["response"].inspect}"
    #logger.info "test post to authorize the request #{token_issuer.inspect}"
    respond_to do |format|
      auth = Base64.strict_encode64("#{@user_session.username}:#{params[:user_session][:password]}")
      response = RestClient.post("#{UAA_TOKEN_SERVER}/oauth/token", {"grant_type" => "client_credentials"}, {"content-type"=>"application/x-www-form-urlencoded;charset=utf-8", "accept"=>"application/json;charset=utf-8", "authorization"=>"Basic #{auth}"}) \
      {|response, request, result, &block| response

      if response.code == 200
        check_user = User.find_by_username(params[:user_session][:username])
        logger.info("Inspecting post_request_for_user_info   #{session.inspect} ########")
        access_token = Yajl::Parser.new.parse(response.body)["access_token"]
        token_type = Yajl::Parser.new.parse(response.body)["token_type"]
        if (!check_user)
          passchars = [('a'..'z'),('A'..'Z'),('1'..'9')].map{|i| i.to_a}.flatten;
          pass = (0..50).map{ passchars[rand(passchars.length)]  }.join;
          user = User.new :username => params[:user_session][:username], :password => pass, :password_confirmation => pass
          user.save!
          @user_session = UserSession.new user
        else
          @user_session = UserSession.new check_user
        end
        session[:access_token] = access_token
        session[:token_type] = token_type
        logger.info("Inspecting post_request_for_user_info   #{session.inspect} ########")
        if @user_session.save
          format.html { redirect_to root_path, notice: 'User login successful .' }
          format.json { render json: @user_session, status: :created, location: @user_session }
        end

      else
        flash[:notice] = 'Wrong Credentials'
        format.html { render action: "new" }
        format.json { render json: "Invalid", status: :created }

      end
      }

    end
  end

  # DELETE /user_sessions/1
  # DELETE /user_sessions/1.json
  def destroy
    @user_session = UserSession.find(params[:id])
    @user_session.destroy

    respond_to do |format|
      format.html { redirect_to user_sessions_url }
      format.json { head :no_content }
    end
  end
end
