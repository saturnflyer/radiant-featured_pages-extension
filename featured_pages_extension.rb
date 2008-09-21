class FeaturedPagesExtension < Radiant::Extension
  version "1"
  description "Adds featured_page field to all pages to allow listing of pages marked regardless of their nesting within parent pages."
  url "http://www.saturnflyer.com/"
  
  def activate
    Page.class_eval { 
      include FeaturedPagesTags
      include PageExtensions
    }
    admin.page.edit.add :form, "featured_page_meta"
    if admin.respond_to?(:dashboard)
      admin.dashboard.index.add :extensions, 'featured_pages'
    end
  end
  
  def deactivate
  end
  
end