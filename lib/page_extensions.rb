module PageExtensions
  def self.included(base)
    base.class_eval {
      named_scope :featured, {:conditions => ["featured_date is NOT NULL"]}
    }
  end
end