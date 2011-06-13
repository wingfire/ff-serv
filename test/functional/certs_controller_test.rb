require 'test_helper'

class CertsControllerTest < ActionController::TestCase

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:certs)
  end

  test "should enforce mac a password" do
    get :ap_cert
    assert_response 401
  end
  test "mac as password, mac as username and password != username should work" do
    @request.env["HTTP_AUTHORIZATION"] = "Basic " + Base64::encode64("e0-f8-47-42-7c-2a:c8-2a-14-2c-f6-c5")
    get :ap_cert, :format => :key
    assert_response :success
    @request.env["HTTP_AUTHORIZATION"] =  nil
  end
  test "username = password should not work" do
    @request.env["HTTP_AUTHORIZATION"] = "Basic " + Base64::encode64("e0-f8-47-42-7c-2a:e0-f8-47-42-7c-2a")
    get :ap_cert, :format => :key
    assert_response 401
    @request.env["HTTP_AUTHORIZATION"] =  nil
  end
  test "Calling .pem prior to .key should respond by 404" do
    @request.env["HTTP_AUTHORIZATION"] = "Basic " + Base64::encode64("CC-f8-47-42-7c-2a:AA-f8-47-42-8c-2a")
    get :ap_cert, :format => :pem
    assert_response 404
    @request.env["HTTP_AUTHORIZATION"] =  nil
  end
  test "Calling .pem after .key should work" do
    @request.env["HTTP_AUTHORIZATION"] = "Basic " + Base64::encode64("bb-f8-47-42-7c-2a:bb-f8-47-42-8c-2c")
    get :ap_cert, :format => :key
    assert_response 200
    get :ap_cert, :format => :pem
    assert_response 200
    @request.env["HTTP_AUTHORIZATION"] =  nil
  end

end
