class AddCertDataToCert < ActiveRecord::Migration
  def self.up
    add_column :certs, :cert_data, :blob
  end

  def self.down
    remove_column :certs, :cert_data
  end
end
