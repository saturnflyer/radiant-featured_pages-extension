require 'ap'
module FeaturedPagesTags
  include Radiant::Taggable
  
  desc %{ 
    Sets the scope for featured pages.
  
    *Usage:*
    <pre><code><r:featured_pages>...</r:featured_pages></code></pre>
  }
  tag 'featured_pages' do |tag|
    tag.expand
  end
  
  desc %{
    Loops over individual pages from the featured_pages scope.
    Accepts these parameters:
    
      * order - 'featured_date ASC' default
      * limit - '10' defaults to no limit
      * date - no default
      * format - used only with the date parameters to specify the format of the date you are using
      * window - '+3 days' no default, allows you to add(+n) or subtract(-n) days, weeks, months, years
      * offset - '-1 month' no default, allows you to offset the actual date from the date given
      
    *Usage:*
    <pre><code><r:featured_pages:each [limit="1" order="published_at ASC"]>...</r:featured_pages:each></code></pre>
  }
  tag 'featured_pages:each' do |tag|
    find_options = {:conditions => ["virtual = ?",false]}
    
    order = tag.attr["order"] || 'featured_date ASC'
    find_options.merge!(:order => order) if order
    
    limit = tag.attr["limit"] || nil
    find_options.merge!(:limit => limit) if limit
    
    date = tag.attr["date"] || nil
    @i18n_date_formats ||= (I18n.config.backend.send(:translations)[I18n.locale][:date][:formats] rescue {})
    format = tag.attr['format']
    if format
      format = @i18n_date_formats.keys.include?(format.to_sym) ? format.to_sym : format
    else
      format = "%m/%d/%Y"
    end
    
    offset_pair = change_pairs(tag.attr['offset'])
    window_pair = change_pairs(tag.attr['window'])
    
    if date
      date_finder = case date
      when /today/
        Rails.env.test? ? Time.zone.now - 1.second : Time.zone.now
      else
        I18n.l(date, :format => format).in_time_zone
      end
      date_with_offset = date_finder.in_time_zone + offset_pair.first.send(offset_pair.last)
      
      if window_pair.first >= 0
        find_options[:conditions].first << ' and featured_date >= ?'
      else
        find_options[:conditions].first << ' and featured_date <= ?'
      end
      find_options[:conditions] << date_with_offset
      
      date_with_window = date_with_offset + window_pair.first.send(window_pair.last)
      
      if window_pair.first == 0
        find_options[:conditions].first << ' and featured_date < ?'
        find_options[:conditions] << date_with_window.end_of_day
      else
        if window_pair.first > 0
          find_options[:conditions].first << ' and featured_date < ?'
        elsif window_pair.first < 0
          find_options[:conditions].first << ' and featured_date > ?'
        end 
        find_options[:conditions] << date_with_window
      end
    end
    
    tag.locals.featured_pages = Page.featured.all(find_options)
    
    result = []
    tag.locals.featured_pages.each do |p|
      tag.locals.page = p
      result << tag.expand
    end
    result
  end
  
  desc %{
    Displays it's contents for the first page from the featured_pages scope
    
    *Usage:*
    <pre><code><r:featured_pages:each><r:if_first>...</r:if_first></r:featured_pages:each></code></pre>
  }
  tag 'featured_pages:each:if_first' do |tag|
    tag.expand if tag.locals.page == tag.locals.featured_pages.first
  end
  
  desc %{
    Displays it's contents for all pages that are not the first page in the featured_pages scope.
    
    *Usage:*
    <pre><code><r:featured_pages:each><r:unless_first>...</r:unless_first></r:featured_pages:each></code></pre>
  }
  tag 'featured_pages:each:unless_first' do |tag|
    tag.expand unless tag.locals.page == tag.locals.featured_pages.first
  end
  
  private
  
  def change_pairs(text='')
    text ||= ''
    change_parts = text.split(' ')
    num = change_parts.first.to_i
    unit = change_parts.last =~ /^(second|minute|hour|day|week|month|year)s?$/ ? change_parts.last : 'days'
    [num, unit]
  end
end