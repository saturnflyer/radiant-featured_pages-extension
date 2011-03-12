module RadiantFeaturedPagesExtension
  module PageExtensions
    def self.included(base)
      base.class_eval {
        named_scope :featured, {:conditions => ["featured_date is NOT NULL"]}
        named_scope :featured_before, lambda{|date|
          {:conditions => ['featured_date is NOT NULL and featured_date < ?',date],
            :order => 'featured_date DESC, id ASC'}
        }
      }
    end
  end
end