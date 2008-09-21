class CreateFeaturedPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :featured_page, :boolean, :default => false
    Page.update_all(['featured_page = ?',false])
  end

  def self.down
    remove_column :pages, :featured_page
  end
end
