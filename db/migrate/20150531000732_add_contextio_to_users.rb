class AddContextioToUsers < ActiveRecord::Migration
  def change
    add_column :users, :contextio_key, :string
    add_column :users, :contextio_secret, :string
  end
end
