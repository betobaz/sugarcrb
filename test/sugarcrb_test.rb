require 'test_helper'

describe "Sugarcrm" do

  before do
    @sugarcrm = Sugarcrb.new("http://lowes.merxbp.loc","admin","Lowes2017","tests","sugar","")
  end

  describe "Cuando se inicializa la Clase" do
    it "Debe de tener valores" do
      assert_equal "admin", @sugarcrm.username
    end
  end

  describe "Cuando hace login" do
    it "Debe de obtener respuesta valida" do
      stub_request(:post, "http://lowes.merxbp.loc/rest/v10/oauth2/token")
        .with(body: {"grant_type":"password","client_id":"sugar","client_secret":"","username":"admin","password":"Lowes2017","platform":"tests"})
        .to_return(status: 200, body: '{"access_token":"AAA","refresh_token":"RRR"}', headers: {})

      response = JSON.load(@sugarcrm.oauth2_token)
      assert_equal "AAA", response['access_token']
      assert_equal "RRR", response['refresh_token']
      assert_equal "AAA", @sugarcrm.access_token
      assert_equal "RRR", @sugarcrm.refresh_token
    end

    it "Debe de obtener respuesta valida" do
      stub_request(:post, "http://lowes.merxbp.loc/rest/v10/oauth2/token")
        .to_return(status: 401, body: '{"error":"need_login","error_message":"Debe especificar un usuario y contrase\u00f1a v\u00e1lidos."}', headers: {})

      assert_raises RuntimeError do
        @sugarcrm.oauth2_token
      end

      assert_empty @sugarcrm.instance_variable_get("@access_token")
      assert_empty @sugarcrm.instance_variable_get("@refresh_token")
    end

    it "Debe de obtener respuesta valida" do
      @sugarcrm.refresh_token = "RRR"
      stub_request(:post, "http://lowes.merxbp.loc/rest/v10/oauth2/token")
        .with(body: {"grant_type":"refresh_token","refresh_token":"RRR","client_id":"sugar","client_secret":""})
        .to_return(status: 200, body: '{"access_token":"AA1","refresh_token":"RR1"}', headers: {})

      response = JSON.load(@sugarcrm.oauth2_refresh_token)
      assert_equal "AA1", response['access_token']
      assert_equal "RR1", response['refresh_token']
      assert_equal "AA1", @sugarcrm.access_token
      assert_equal "RR1", @sugarcrm.refresh_token
    end

  end

  describe "Cuando llama el api" do
    it "Debe de crear un registro con peticion valida" do
      @sugarcrm.access_token = "AAA"
      @sugarcrm.refresh_token = "RRR"

      stub_request(:post, "http://lowes.merxbp.loc/rest/v10/Accounts")
        .with(headers: { 'OAuth-Token' => "AAA" })
        .to_return(status: 200, body: '{"id":"SUGARID","name":"Account name"}', headers: {})

      response = JSON.load(@sugarcrm.call("post", "Accounts",{
        "name" => "Account name"
      }))

      assert_equal "SUGARID", response['id']
      assert_equal "Account name", response['name']
    end

    it "Debe de crear un registro con peticion invalida por token expirado" do
      @sugarcrm.access_token = "AAA"
      @sugarcrm.refresh_token = "RRR"

      stub_request(:post, "http://lowes.merxbp.loc/rest/v10/Accounts")
        .with(headers: { 'OAuth-Token' => "AAA" })
        .to_return(status: 401, body: '{"error":"invalid_grant","error_message":"The access token provided is invalid."}', headers: {})

      stub_request(:post, "http://lowes.merxbp.loc/rest/v10/oauth2/token")
        .with(body: {"grant_type":"refresh_token","refresh_token":"RRR","client_id":"sugar","client_secret":""})
        .to_return(status: 200, body: '{"access_token":"AA1","refresh_token":"RR1"}', headers: {})

      stub_request(:post, "http://lowes.merxbp.loc/rest/v10/Accounts")
        .with(headers: { 'OAuth-Token' => "AA1" })
        .to_return(status: 200, body: '{"id":"SUGARID","name":"Account name"}', headers: {})

      response = JSON.load(@sugarcrm.call("post", "Accounts",{
        "name" => "Account name"
      }))

      assert_equal "SUGARID", response['id']
      assert_equal "Account name", response['name']
      assert_equal "AA1", @sugarcrm.access_token
      assert_equal "RR1", @sugarcrm.refresh_token
    end

    it "Debe de crear un registro con peticion invalida por token expirado y refresh_token expirado" do
      @sugarcrm.access_token = "AAA"
      @sugarcrm.refresh_token = "RRR"

      stub_request(:post, "http://lowes.merxbp.loc/rest/v10/Accounts")
        .with(headers: { 'OAuth-Token' => "AAA" })
        .to_return(status: 401, body: '{"error":"invalid_grant","error_message":"The access token provided is invalid."}', headers: {})

      stub_request(:post, "http://lowes.merxbp.loc/rest/v10/oauth2/token")
        .with(body: {"grant_type":"refresh_token","refresh_token":"RRR","client_id":"sugar","client_secret":""})
        .to_return(status: 401, body: '{"error":"need_login","error_message":"Debe especificar un usuario y contrase\u00f1a v\u00e1lidos."}', headers: {})

      stub_request(:post, "http://lowes.merxbp.loc/rest/v10/oauth2/token")
        .with(body: {"grant_type":"password","client_id":"sugar","client_secret":"","username":"admin","password":"Lowes2017","platform":"tests"})
        .to_return(status: 200, body: '{"access_token":"AA2","refresh_token":"RR2"}', headers: {})

      stub_request(:post, "http://lowes.merxbp.loc/rest/v10/Accounts")
        .with(headers: { 'OAuth-Token' => "AA2" })
        .to_return(status: 200, body: '{"id":"SUGARID","name":"Account name"}', headers: {})

      response = JSON.load(@sugarcrm.call("post", "Accounts",{
        "name" => "Account name"
      }))

      assert_equal "SUGARID", response['id']
      assert_equal "Account name", response['name']
      assert_equal "AA2", @sugarcrm.access_token
      assert_equal "RR2", @sugarcrm.refresh_token
    end

    it "Debe de listar un registro con peticion valida empty" do
      @sugarcrm.access_token = "AAA"

      stub_request(:get, "http://lowes.merxbp.loc/rest/v10/Accounts")
        .with(headers: { 'OAuth-Token' => "AAA" })
        .to_return(status: 200, body: '{"next_offset":-1,"records":[]}', headers: {})

      response = JSON.load(@sugarcrm.call("get", "Accounts"))

      assert_equal -1, response['next_offset']
      assert_equal 0, response['records'].length
    end

    it "Debe de listar un registro con peticion valida con un elemento" do
      @sugarcrm.access_token = "AAA"

      stub_request(:get, "http://lowes.merxbp.loc/rest/v10/Accounts")
        .with(headers: { 'OAuth-Token' => "AAA" })
        .to_return(status: 200, body: '{"next_offset":20,"records":[{"id":"AAA","name":"Account Name"}]}', headers: {})

      response = JSON.load(@sugarcrm.call("get", "Accounts"))

      assert_equal 20, response['next_offset']
      assert_equal 1, response['records'].length
    end

    it "Debe de obtener un registro con peticion valida " do
      @sugarcrm.access_token = "AAA"

      stub_request(:get, "http://lowes.merxbp.loc/rest/v10/Accounts/AAA")
        .with(headers: { 'OAuth-Token' => "AAA" })
        .to_return(status: 200, body: '{"id":"AAA","name":"Account Name"}', headers: {})

      response = JSON.load(@sugarcrm.call("get", "Accounts/AAA"))

      assert_equal "AAA", response['id']
      assert_equal "Account Name", response['name']
    end

    it "Debe de actualizar un registro con peticion valida " do
      @sugarcrm.access_token = "AAA"

      stub_request(:put, "http://lowes.merxbp.loc/rest/v10/Accounts/AAA")
        .with(headers: { 'OAuth-Token' => "AAA" })
        .to_return(status: 200, body: '{"id":"AAA","name":"Account Name Change"}', headers: {})

      response = JSON.load(@sugarcrm.call("put", "Accounts/AAA", {"name"=>"Account Name Change"}))

      assert_equal "AAA", response['id']
      assert_equal "Account Name Change", response['name']
    end

    it "Debe de eliminar un registro con peticion valida " do
      @sugarcrm.access_token = "AAA"

      stub_request(:delete, "http://lowes.merxbp.loc/rest/v10/Accounts/AAA")
        .with(headers: { 'OAuth-Token' => "AAA" })
        .to_return(status: 200, headers: {})

      response = @sugarcrm.call("delete", "Accounts/AAA")
      assert_equal 200, response.code
    end
  end


end
