class ClientsController < ApplicationController
  # GET /clients
  # GET /clients.json
  include HTTParty

  def index
    def index
      data = HTTParty.get("#{UAA_TOKEN_SERVER}/oauth/clients",
                           :headers => {
                               'Content-Type' => 'application/json',
                               'Authorization' => "bearer #{session[:access_token]}",
                               'Accept' => 'application/json'
                           } )
      logger.info("Inspecting response   #{data.inspect} ########")
      #logger.info("Inspecting response   #{@clients.inspect} ########")
      #logger.info("Inspecting response   #{@users["resources"].inspect} ########")
      @clients  = data["resources"]
      #@users = User.all
      logger.info("Inspecting response   #{@clients.inspect} ########")

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @clients }
      end
    end

  end

  # GET /clients/1
  # GET /clients/1.json
  def show
    @client = Client.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @client }
    end
  end

  # GET /clients/new
  # GET /clients/new.json
  def new
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /clients/1/edit
  def edit
    @client = Client.find(params[:id])
  end

  # POST /clients
  # POST /clients.json
  def create
    @client = Client.new(params[:client])

    parameters = ActiveSupport::JSON::encode(api_call_data(params[:client]))
    logger.info("#####{@client}")
    logger.info("#####{parameters}")
    respond_to do |format|
      @result = HTTParty.post("#{UAA_TOKEN_SERVER}/oauth/clients",
                              :body => parameters,
                              :headers => {
                                  'Content-Type' => 'application/json',
                                  'Authorization' => "Bearer #{session[:access_token]}",
                                  'Accept' => 'application/json'
                              } )
      logger.info("###### respo #{@result.inspect}")
      if @client.save
        format.html { redirect_to @client, notice: 'Client was successfully created.' }
        format.json { render json: @client, status: :created, location: @client }
      else
        format.html { render action: "new" }
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /clients/1
  # PUT /clients/1.json
  def update
    @client = Client.find(params[:id])

    respond_to do |format|
      if @client.update_attributes(params[:client])
        format.html { redirect_to @client, notice: 'Client was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /clients/1
  # DELETE /clients/1.json
  def destroy
    @client = Client.find(params[:id])
    @client.destroy

    respond_to do |format|
      format.html { redirect_to clients_url }
      format.json { head :no_content }
    end
  end

  private

  def api_call_data options
    {
        "client_id" => options[:client_id],

        "scope" => [uaa.none],
        "resource_ids" => [none],
        "authorities" => [cloud_controller.read,cloud_controller.write,scim.read],
        "authorized_grant_types" => [client_credentials]
    }
  end
end
