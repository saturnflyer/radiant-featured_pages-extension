Featured Pages selects from all pages (that are not virtual pages) and
currently accepts parameters limit and/or order.

  <r:featured_pages [limit="1" order="published_at ASC"]>
  <h2>Featured Pages</h2>
  	<r:each>
  	<r:content /> ...etc...
  	</r:each>
  </r:featured_pages>

Other tags provided are `r:featured_pages:if_first` and 
`r:featured_pages:unless_first` which will return or exclude the first 
featured_page in the collection.

If you have Dashboard installed, you will see a list of your featured pages
on the Dashboard.

Built by Saturn Flyer http://www.saturnflyer.com