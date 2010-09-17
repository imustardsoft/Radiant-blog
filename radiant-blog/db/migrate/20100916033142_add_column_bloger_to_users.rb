class AddColumnBlogerToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :bloger, :boolean, :default => false
  end

  def self.down
    remove_column :comments, :bloger
  end
end
