class CertsController < ApplicationController
  before_filter :authenticate_mac, :only => :ap_cert
  # GET /certs
  # GET /certs.xml
  def index
    @certs = Cert.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @certs }
    end
  end


  # DELETE /certs/1
  # DELETE /certs/1.xml
  #def destroy
  #  @cert = Cert.find(params[:id])
  #  @cert.destroy#

  #  respond_to do |format|
  #    format.html { redirect_to(certs_url) }
  #    format.xml  { head :ok }
  #  end
  #end
  
  ## GET /certs/ap_cert
  def ap_cert
    respond_to do |format|
      #.key has to be called first ... it generates a certificate
      #This is done for security reasons: Keys are not stored ... thus they have to be retrieved first.
      format.key { render :text => Cert.create_by_wlan_and_lan(session[:wlan_mac],session[:eth0_mac]).cert_key.to_pem}
      #.pem can be called later on ... it sends a certificat
      format.pem do
        if cert = Cert.last(:conditions => ['wlan_mac = ? AND eth0_mac = ?',session[:wlan_mac],session[:eth0_mac]])
          render :text => cert.cert_data
        else
          render :status => 404, :text => "Please download ap_cert.key first - it'll create your certificate"
        end
      end
    end
    
  end
  
  
  ## GET /certs/ca_cert.pem
  def ca_cert
    render :text => Cert.ca_cert
  end
  
  ## GET /certs/dh1024.pem
  def dh1024
    render :text => OpenSSL::PKey::DH.generate(1024).to_pem
  end
  
  def sign_csr
  end
  
  #Authenticate for Cert-Request:
  #User: Mac of wlan module
  #Password: Mac of first wired nic (eg eth0)
  private
  def authenticate_mac
    authenticate_or_request_with_http_basic do |username, password|
        logger.error "Credentials #{username} #{password}"
        #Regular expression matches for HW-addresses stolen and modified from http://www.perlmonks.org/?node_id=83405
        session[:wlan_mac] = username
        session[:eth0_mac] = password
        username.match(/^([0-9a-f]{2}(-|$)){6}$/i) && password.match(/^([0-9a-f]{2}(-|$)){6}$/i) && username != password
      end
  end
    
end
