module PageExtensions
  def self.included(base)
    base.class_eval {
      def self.featured
        self.find(:all, :conditions => {:featured_page => true})
      end
    }
  end
end