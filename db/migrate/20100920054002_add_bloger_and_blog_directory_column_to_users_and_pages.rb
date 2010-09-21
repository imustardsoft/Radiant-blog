class AddBlogerAndBlogDirectoryColumnToUsersAndPages < ActiveRecord::Migration
  def self.up
    add_column :users, :bloger, :boolean, :default => false
    add_column :pages, :blog_directory, :boolean, :default => false
  end

  def self.down
    remove_column :users, :bloger
    remove_column :pages, :blog_directory
  end
end
