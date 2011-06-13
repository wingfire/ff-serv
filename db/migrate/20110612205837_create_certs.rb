class CreateCerts < ActiveRecord::Migration
  def self.up
    create_table :certs do |t|
      t.string :wlan_mac
      t.string :eth0_mac
      t.string :fingerprint
      t.string :requesting_ip

      t.timestamps
    end
  end

  def self.down
    drop_table :certs
  end
end
