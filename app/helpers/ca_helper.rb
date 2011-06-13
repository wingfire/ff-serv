module CaHelper

  ##Easy-RSA-Stuff
  def easy_rsa_ca_cert(*args,&block)
    @@cert ||= File.read(ca_config['key_path']+"/ca.crt")
  end
  
  #CA-Methods
  #See: http://seattlerb.rubyforge.org/quick_cert/QuickCert.html for details
  #Since no "good" openssl api doc is available, we follow that class.
  
  ## Generate a new OpenSSL keypair
  def openssl_generate_key(*args,&block)
    keypair = OpenSSL::PKey::RSA.new ca_config['key_size']
  end
  
  ## Generate a OpenSSL CSR
  def openssl_create_csr(*args,&block)
    key = args[0][:key]
    name = OpenSSL::X509::Name.new [['CN', "To be detailed"]]
    req = OpenSSL::X509::Request.new
    req.version = 0
    req.subject = name
    req.public_key = key.public_key
    req.sign key, OpenSSL::Digest::SHA1.new
    req
  end
  
  ##Sign a CSR
  def openssl_sign_csr(*args,&block)
    #Read CA Data
    csr = args[0][:csr]
    cn = args[0][:cn]
    name = OpenSSL::X509::Name.new [['CN', cn]]
    ca = OpenSSL::X509::Certificate.new easy_rsa_ca_cert
    ca_keypair = OpenSSL::PKey::RSA.new easy_rsa_ca_key
    serial = File.read(ca_config['key_path']+"/serial").chomp.hex
    open ca_config['key_path']+"/serial", "w" do |f|
      f << "%04X" % (serial + 1)
    end
    #Build new certificate
    cert = OpenSSL::X509::Certificate.new
    from = Time.now
    cert.subject = name
    cert.issuer = ca.subject
    cert.not_before = from
    cert.not_after = from + 365 * 10 * 24 * 60 * 60 #10 years
    cert.public_key = csr.public_key
    cert.serial = serial
    cert.version = 2 # X509v3
    #Type is client
    #Cert attributes
    basic_constraint = "CA:FALSE"
    key_usage = ["nonRepudiation","digitalSignature","keyEncipherment"]
    ext_key_usage = ["clientAuth"]
    
    #Write cert attributes as extensions
    ef = OpenSSL::X509::ExtensionFactory.new
    ef.subject_certificate = cert
    ef.issuer_certificate = ca
    ex = []
    ex << ef.create_extension("basicConstraints", basic_constraint, true)
    ex << ef.create_extension("nsComment",
                              "Freifunk-KBU/Ruby/OpenSSL Generated Certificate")
    ex << ef.create_extension("subjectKeyIdentifier", "hash")
    ex << ef.create_extension("nsCertType", "client")
    ex << ef.create_extension("keyUsage", key_usage.join(","))
    ex << ef.create_extension("extendedKeyUsage", ext_key_usage.join(","))
    cert.extensions = ex
    cert.sign ca_keypair, OpenSSL::Digest::SHA1.new
    cert
  end
  
  private
  def ca_config
    @@ca_config ||= YAML::load_file("#{RAILS_ROOT}/config/ssl.yml")[RAILS_ENV]
  end
  def easy_rsa_ca_key(*args,&block)
    @@key ||= File.read(ca_config['key_path']+"/ca.key")
  end
end
