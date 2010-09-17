class AddColumnBlogDirectoryToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :blog_directory, :boolean, :default => false
  end

  def self.down
    remove_column :comments, :blog_directory
  end
end
