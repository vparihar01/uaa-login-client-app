class UsersController < ApplicationController
  # GET /users
  # GET /users.json
  include HTTParty
  before_filter :require_user
  def index
    data = RestClient.get "#{UAA_TOKEN_SERVER}/Users", { 'Authorization' => "Bearer #{session[:access_token]}" }
    @users = JSON.parse(data)
    logger.info("Inspecting response   #{data.inspect} ########")
    #logger.info("Inspecting response   #{@users["resources"].inspect} ########")
    @users  = @users["resources"]
    #@users = User.all
    logger.info("Inspecting response   #{@users.inspect} ########")

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    respond_to do |format|
      @user = HTTParty.get("#{UAA_TOKEN_SERVER}/Users/#{params[:id]}",
                           :headers => {
                               'Content-Type' => 'application/json',
                               'Authorization' => "Bearer #{session[:access_token]}",
                               'Accept' => 'application/json'
                           } )
      logger.info("###### respo #{@user.inspect}")
      #response = RestClient.post("#{UAA_TOKEN_SERVER}/Users", {'Content-Type' => "application/json"},{:content_type => 'text/plain'}) \
      #{|response, request, result, &block| response
      #logger.info("###### respo #{request.inspect}")
      #logger.info("###### respo #{JSON.parse(response)}")
      #
      if @user.success?
        logger.info("###### respo #{@user.inspect}")
        format.html
      else
        flash[:warn] = @result["message"]
        format.html { redirect_to user_path}
      end
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    respond_to do |format|
      @user = HTTParty.get("#{UAA_TOKEN_SERVER}/Users/#{params[:id]}",
                           :headers => {
                               'Content-Type' => 'application/json',
                               'Authorization' => "Bearer #{session[:access_token]}",
                               'Accept' => 'application/json'
                           } )
      logger.info("###### respo #{@user.inspect}")
      #response = RestClient.post("#{UAA_TOKEN_SERVER}/Users", {'Content-Type' => "application/json"},{:content_type => 'text/plain'}) \
      #{|response, request, result, &block| response
      #logger.info("###### respo #{request.inspect}")
      #logger.info("###### respo #{JSON.parse(response)}")
      #
      if @user.success?
        logger.info("###### respo #{@user.inspect}")
        format.html
      else
        flash[:warn] = @result["message"]
        format.html { redirect_to user_path}
      end
    end
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new params[:user]
    parameters = ActiveSupport::JSON::encode(params_for_api_call(params[:user]))
    logger.info("#####{@user}")
    logger.info("#####{parameters}")
    respond_to do |format|
      @result = HTTParty.post("#{UAA_TOKEN_SERVER}/Users",
                              :body => parameters,
                              :headers => {
                                  'Content-Type' => 'application/json',
                                  'Authorization' => "Bearer #{session[:access_token]}",
                                  'Accept' => 'application/json'
                              } )
      logger.info("###### respo #{@result.inspect}")
      #response = RestClient.post("#{UAA_TOKEN_SERVER}/Users", {'Content-Type' => "application/json"},{:content_type => 'text/plain'}) \
      #{|response, request, result, &block| response
      #logger.info("###### respo #{request.inspect}")
      #logger.info("###### respo #{JSON.parse(response)}")
      #
      if @result.success?
        logger.info("###### respo #{@result.inspect}")
        format.html { redirect_to user_path(@result["id"]), notice: 'User Created successful .' }
        format.json { render json: @user, status: :created, location: @user }
      else
        flash[:notice] = @result["message"]
        format.html { render action: "new"}
        format.json { render json: "error", status: :unprocessable_entity }
      end
      #}
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    parameters = ActiveSupport::JSON::encode(params_for_api_call_update(params[:user]))
    logger.info("###### response #{parameters}")
    respond_to do |format|
      @user = HTTParty.put("#{UAA_TOKEN_SERVER}/Users/#{params["id"]}",
                              :body => parameters,
                              :headers => {
                                  'Content-Type' => 'application/json',
                                  'Authorization' => "bearer #{session[:access_token]}",
                                  'Accept' => 'application/json',
                                  'If-Match' => "2"
                              } )
      logger.info("###### respo #{@user.inspect}")
      #response = RestClient.post("#{UAA_TOKEN_SERVER}/Users", {'Content-Type' => "application/json"},{:content_type => 'text/plain'}) \
      #{|response, request, result, &block| response
      #logger.info("###### respo #{request.inspect}")
      #logger.info("###### respo #{JSON.parse(response)}")
      #
      if @user.success?
        logger.info("###### respo #{@user.inspect}")
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render json: @user, status: :created, location: @user }
      else
        flash[:notice] = @user["message"]
        format.html { render action: "edit"}
        format.json { render json: "error", status: :unprocessable_entity }
      end
      #}
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = HTTParty.delete("#{UAA_TOKEN_SERVER}/Users/#{params["id"]}",
                         :headers => {
                             'Content-Type' => 'application/json',
                             'Authorization' => "Bearer #{session[:access_token]}",
                             'Accept' => 'application/json',
                         } )

    respond_to do |format|
      format.html { redirect_to users_path }
      format.json { head :no_content }
    end
  end

  private

  def params_for_api_call_update options
    {
        "title" => options[:title],
        "name" => {
            "givenName" => options[:name]
        },
        "emails" => [{
                         "value" => options[:email]
                     }]
    }
  end

  def params_for_api_call options
    {
        "userName" => options[:username],
        "title" => options[:title],
        "password" => options[:password],
        "name" => {
            "givenName" => options[:givenName]
        },
        "emails" => [{
                         "value" => options[:email]
                     }]
    }
  end
end
