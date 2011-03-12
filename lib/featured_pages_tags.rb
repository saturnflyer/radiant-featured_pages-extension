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
    
      * order  - 'featured_date ASC' default
      * limit  - '10' defaults to no limit
      * date   - no default
      * format - used only with the date parameters to specify the format of the date you are using
      * window - '+3 days' no default, allows you to add(+n) or subtract(-n) days, weeks, months, years
      * offset - '-1 month' no default, allows you to offset the actual date from the date given
      
    *Usage:*
    <pre><code><r:featured_pages:each [limit="1" order="published_at ASC"]>...</r:featured_pages:each></code></pre>
  }
  tag 'featured_pages:each' do |tag|
    find_options = {:conditions => ["virtual = ?",false]}
    
    order = tag.attr["order"] || 'featured_date DESC'
    find_options.merge!(:order => order) if order
    
    limit = tag.attr["limit"] || nil
    find_options.merge!(:limit => limit) if limit
    
    date = tag.attr["date"] || nil
    
    format = tag.attr['format']
    format = i18n_date_formats[format] || "%m/%d/%Y"
    
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
  
  desc %{
    Displays it's contents if the current page is featured in the given window of time.
    Accepts these parameters:
      
      * date   - no default. Use a formatted date or 'today', 'future', or 'past'
      * format - used only with the date parameters to specify the format of the date you are using
      * window - '+3 days' no default, allows you to add(+n) or subtract(-n) days, weeks, months, years
      * offset - '-1 month' no default, allows you to offset the actual date from the date given
      * latest - 'true' or 'false'. Defaults to 'false'. Expands only if the page is the latest feature
      
    Selecting a date of 'future' or 'past' will expand the window to any time in the future or past
    beyond the offset.
      
    *Usage:*
    <pre><code><r:if_featured>...</r:if_featured></code></pre>
  }
  tag 'if_featured' do |tag|
    date = tag.attr["date"] || nil
    latest = tag.attr['latest'] || false
    
    if date || latest == 'true'
      offset_pair = change_pairs(tag.attr['offset'])
      window_pair = change_pairs(tag.attr['window'])
      
      format = tag.attr['format']
      format = i18n_date_formats[format] || "%m/%d/%Y"
      
      focus_date = begin
        I18n.l(date, :format => format).in_time_zone
      rescue
        Rails.env.test? ? Time.zone.now - 1.second : Time.zone.now
      end
      
      date_with_offset = (focus_date.in_time_zone + offset_pair.first.send(offset_pair.last)).beginning_of_day
      date_with_window = (date_with_offset + window_pair.first.send(window_pair.last)).end_of_day
      range_dates = [date_with_offset, date_with_window].sort
      
      in_future_window = (date == 'future' && tag.locals.page.featured_date > date_with_offset)
      in_past_window = (date == 'past' && tag.locals.page.featured_date < date_with_offset)
      in_range_window = (tag.locals.page.featured_date >= range_dates.first.beginning_of_day && tag.locals.page.featured_date <= range_dates.last.end_of_day)
      
      if (latest && Page.featured_before(range_dates.last).first == tag.locals.page) ||
        in_future_window || in_past_window || in_range_window
          tag.expand
      end
    else
      tag.expand if tag.locals.page.featured_date.present?
    end
  end
  
  desc %{
    Displays it's contents if the current page is not featured in the given window of time.
    Accepts the same parameters as if_featured.
      
    *Usage:*
    <pre><code><r:unless_featured>...</r:unless_featured></code></pre>
  }
  tag 'unless_featured' do |tag|
    date = tag.attr["date"] || nil
    latest = tag.attr['latest'] || false
    
    if date || latest
      offset_pair = change_pairs(tag.attr['offset'])
      window_pair = change_pairs(tag.attr['window'])
      
      format = tag.attr['format']
      format = i18n_date_formats[format] || "%m/%d/%Y"
      
      focus_date = begin
        I18n.l(date, :format => format).in_time_zone
      rescue
        Rails.env.test? ? Time.zone.now - 1.second : Time.zone.now
      end
      
      date_with_offset = (focus_date.in_time_zone + offset_pair.first.send(offset_pair.last)).beginning_of_day
      date_with_window = (date_with_offset + window_pair.first.send(window_pair.last)).end_of_day
      range_dates = [date_with_offset, date_with_window].sort
      
      in_future_window = (date == 'future' && tag.locals.page.featured_date > date_with_offset)
      in_past_window = (date == 'past' && tag.locals.page.featured_date < date_with_offset)
      in_range_window = (tag.locals.page.featured_date >= range_dates.first.beginning_of_day && tag.locals.page.featured_date <= range_dates.last.end_of_day)

      unless (latest && Page.featured_before(range_dates.last).first == tag.locals.page) ||
        (in_future_window || in_past_window || in_range_window)
          tag.expand
      end
    else
      tag.expand unless tag.locals.page.featured_date.present?
    end
  end
    
  private
  
  def change_pairs(text='')
    text ||= ''
    change_parts = text.split(' ')
    num = change_parts.first.to_i
    unit = change_parts.last =~ /^(second|minute|hour|day|week|month|year)s?$/ ? change_parts.last : 'days'
    [num, unit]
  end
  
  def date_change_amount(text_or_pair)
    pair = change_pairs(text_or_pair)
    pair.first.send(pair.second)
  end
  
  def i18n_date_formats
    @i18n_date_formats ||= I18n.t('date.formats')
  end
end