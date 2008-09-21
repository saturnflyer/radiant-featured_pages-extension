module FeaturedPagesTags
  include Radiant::Taggable
  
  desc %{ 
    Returns all featured pages. Accepts a limit and/or order parameter.
  
    *Usage:*
    <pre><code><r:featured_pages [limit="1" order="published_at ASC"]>...</r:featured_pages></code></pre>
  }
  tag 'featured_pages' do |tag|
    limit = tag.attr["limit"] || nil
    order = tag.attr["order"] || nil
    find_options = {:conditions => ['featured_page = ? and virtual = ?', true, false]}
    unless order.nil?
      find_options.merge!(:order => order)
    end
    unless limit.nil? 
      find_options.merge!(:limit => limit)
    end
    tag.locals.featured_pages = Page.find(:all, find_options)
    tag.expand unless tag.locals.featured_pages.empty?
  end
  
  desc %{
    Returns an individual page from the featured_pages scope
    
    *Usage:*
    <pre><code><r:featured_pages:each>...</r:featured_pages:each></code></pre>
  }
  tag 'featured_pages:each' do |tag|
    result = []
    tag.locals.featured_pages.each do |p|
      tag.locals.page = p
      result << tag.expand
    end
    result
  end
  
  desc %{
    Returns the first page from the featured_pages scope
    
    *Usage:*
    <pre><code><r:featured_pages><r:if_first>...</r:if_first></r:featured_pages></code></pre>
  }
  tag 'featured_pages:if_first' do |tag|
    pages = tag.locals.featured_pages
    if first = pages.first
      tag.locals.page = first
      tag.expand
    end
  end
  
  desc %{
    Returns all pages that are not the first page in the featured_pages scope.
    
    *Usage:*
    <pre><code><r:featured_pages><r:unless_first>...</r:unless_first></r:featured_pages></code></pre>
  }
  tag 'featured_pages:unless_first' do |tag|
    result = []
    tag.locals.featured_pages.each do |p|
      tag.locals.page = p
      result << tag.expand unless tag.locals.featured_pages.first == p
    end
    result
  end
end