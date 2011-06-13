class RemoveRequestingIpFromCert < ActiveRecord::Migration
  def self.up
    remove_column :certs, :requesting_ip
  end

  def self.down
    add_column :certs, :requesting_ip, :string
  end
end
