# Featured Pages

When listing your featured pages, you have flexible options.

## Code Samples

Basic list:

  <r:featured_pages:each>
    <r:title />
  </r:featured_pages:each>
  
Set a limit:

  <r:featured_pages:each>
    <r:title />
  </r:featured_pages:each>
  
Today's features:
  
  <r:featured_pages:each date="today">
    <r:title />
  </r:featured_pages:each>
  
Features from one month ago:
  
  <r:featured_pages:each date="today" offset="-1 month">
    <r:title />
  </r:featured_pages:each>

Features from one week ago till one month forward:

  <r:featured_pages:each date="today" offset="-1 week" window="+1 month">
    <r:title />
  </r:featured_pages:each>
  