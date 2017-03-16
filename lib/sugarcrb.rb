require "sugarcrb/version"
require 'rest-client'

class Sugarcrb

  def initialize(host, username, password, platform, client_id, client_secret)
    # Instance variables
    @host = host
    @username = username
    @password = password
    @platform = platform
    @client_secret = client_secret
    @client_id = client_id
    @access_token = ""
    @refresh_token = ""
  end

  attr_accessor :username
  attr_accessor :access_token
  attr_accessor :refresh_token

  def oauth2_token (refresh = false)
    data = {
       "grant_type": "password",
       "client_id": @client_id,
       "client_secret": @client_secret,
       "username": @username,
       "password": @password,
       "platform": @platform
    }
    response = RestClient.post "#{@host}/rest/v10/oauth2/token", data
    response_json = JSON.load(response)
    if (response.code == 200) then
      @access_token = response_json['access_token']
      @refresh_token = response_json['refresh_token']
    end
    return response
  end

  def oauth2_refresh_token
    data = {
       "grant_type": "refresh_token",
       "refresh_token": @refresh_token,
       "client_id": @client_id,
       "client_secret": @client_secret,
    }
    begin
      response = RestClient.post "#{@host}/rest/v10/oauth2/token", data
      response_json = JSON.load(response)
      if (response.code == 200) then
        @access_token = response_json['access_token']
        @refresh_token = response_json['refresh_token']
      end
      return response
    rescue RestClient::Unauthorized => err
      return self.oauth2_token
    end
  end

  def call (method, endpoint, data = false, reintents = 0)
    begin
      response = case method
        when "post" then RestClient.post "#{@host}/rest/v10/#{endpoint}", data, headers={"OAuth-Token" => @access_token}
        when "get" then RestClient.get "#{@host}/rest/v10/#{endpoint}", headers={"OAuth-Token" => @access_token}
        when "put" then RestClient.put "#{@host}/rest/v10/#{endpoint}", JSON.generate(data), :"OAuth-Token" => @access_token, :content_type => :json
        when "delete" then RestClient.delete "#{@host}/rest/v10/#{endpoint}", headers={"OAuth-Token" => @access_token}
      end

      return response
    rescue RestClient::Unauthorized => err
      if reintents < 3 then
        self.oauth2_refresh_token
        reintents = reintents + 1
        self.call(method, endpoint, data, reintents)
      end
    end
  end

end
