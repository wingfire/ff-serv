require 'test_helper'

class RequestCertificateTest < ActionDispatch::IntegrationTest
  test "Requesting a key and a certificate should generate key and certifcate" do
    get(
        "/certs/ap_cert.key", nil,
        'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials("bb-f8-47-42-7c-2a","bb-f8-47-42-8c-2c")
      )
    assert_equal 200, status
    assert response.body.match(/BEGIN.+PRIVATE KEY/) && response.body.match(/END.+PRIVATE KEY/)
    get(
        "/certs/ap_cert.pem", nil,
        'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials("bb-f8-47-42-7c-2a","bb-f8-47-42-8c-2c")
      )
    assert_equal 200, status
    assert response.body.match(/BEGIN CERTIFICATE/) && response.body.match(/END CERTIFICATE/)
  end

  test "Requesting ca-certificate should retrun a certificate" do
    get '/certs/ca_cert.pem'
    assert_equal 200, status
    assert response.body.match(/BEGIN CERTIFICATE/) && response.body.match(/END CERTIFICATE/)
  end
end
