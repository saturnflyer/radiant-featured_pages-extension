class AddFeaturedDateToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :featured_date, :datetime
    Page.reset_column_information
    Page.find_in_batches(:conditions => {:featured_page => true}) do |group|
      group.each do |page|
        page.update_attribute(:featured_date, (page.published_at || page.created_at))
      end
    end
    remove_column :pages, :featured_page
  end

  def self.down
    add_column :pages, :featured_page, :boolean, :default => false
    Page.reset_column_information
    Page.find_in_batches(:conditions => ["featured_date is NOT NULL or featured_date != ''"]) do |group|
      page.update_attribute(:featured_page, true)
    end
    remove_column :pages, :featured_date
  end
end
