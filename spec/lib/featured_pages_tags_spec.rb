require File.dirname(__FILE__) + '/../spec_helper'

describe Page do
  let(:page){
    Page.new(:featured_date => Time.zone.now, :slug => 'page', :breadcrumb => 'page', :title => 'page')}
  let(:minus_1_week){
    Page.new(:featured_date => (Time.zone.now - 1.week), :slug => 'minus_1_week', :breadcrumb => 'minus_1_week', :title => 'minus_1_week')}
  let(:plus_1_day){
    Page.new(:featured_date => (Time.zone.now + 1.day), :slug => 'plus_1_day', :breadcrumb => 'plus_1_day', :title => 'plus_1_day')}
  let(:plus_2_days){
    Page.new(:featured_date => (Time.zone.now + 2.days), :slug => 'plus_2_days', :breadcrumb => 'plus_2_days', :title => 'plus_2_days', :virtual => true)}
  let(:plus_2_weeks){
    Page.new(:featured_date => (Time.zone.now + 2.weeks), :slug => 'plus_2_weeks', :breadcrumb => 'plus_2_weeks', :title => 'plus_2_weeks')}
  let(:plus_2_months){
    Page.new(:featured_date => (Time.zone.now + 2.months), :slug => 'plus_2_months', :breadcrumb => 'plus_2_months', :title => 'plus_2_months')}
  let(:plus_2_years){
    Page.new(:featured_date => (Time.zone.now + 2.years), :slug => 'plus_2_years', :breadcrumb => 'plus_2_years', :title => 'plus_2_years')}

  def save_pages
    # saving with false so it still saves when other extensions are present
    page.save(false) and 
      minus_1_week.save(false) and
      plus_1_day.save(false) and 
      plus_2_days.save(false) and
      plus_2_weeks.save(false) and
      plus_2_months.save(false) and
      plus_2_years.save(false)
  end

  describe "<r:featured_pages>" do
    it "should truncate the contents to the given length" do
      page.should render('<r:featured_pages>Featured!</r:featured_pages>').as('Featured!')
    end
  end
  
  describe "<r:featured_pages:each>" do
    before do
      save_pages
    end
    it "should output the contents for each featured page" do
      page.should render('<r:featured_pages:each><r:title /> </r:featured_pages:each>').as('minus_1_week page plus_1_day plus_2_weeks plus_2_months plus_2_years ')
    end
    it "should not find virtual pages" do
      page.should render('<r:featured_pages:each><r:title /> </r:featured_pages:each>').as('minus_1_week page plus_1_day plus_2_weeks plus_2_months plus_2_years ')
    end
    it "should limit the pages by the 'limit' attribute" do
      page.should render('<r:featured_pages:each limit="1"><r:title /> </r:featured_pages:each>').as('minus_1_week ')
    end
    it "should order the pages by the 'order' attribute" do
      page.should render('<r:featured_pages:each order="featured_date DESC"><r:title /> </r:featured_pages:each>').as('plus_2_years plus_2_months plus_2_weeks plus_1_day page minus_1_week ')
    end
    it "should find pages featured on a given 'date'" do
      page.should render('<r:featured_pages:each date="today"><r:title /> </r:featured_pages:each>').as('page ')
    end
    it "should find pages featured today when the given 'date' is 'today'" do
      page.should render('<r:featured_pages:each date="today"><r:title /> </r:featured_pages:each>').as('page ')
    end
    
    it "should find pages featured between the given 'date' and and that date plus the 'window'" do
      page.should render('<r:featured_pages:each date="today" window="1 month"><r:title /> </r:featured_pages:each>').as('page plus_1_day plus_2_weeks ')
    end
    it "should find pages featured between the given 'date' plus the 'offset'" do
      page.should render('<r:featured_pages:each date="today" offset="-7 days"><r:title /> </r:featured_pages:each>').as('minus_1_week ')
    end
    it "should find pages featured limited in number by the given 'limit'" do
      page.should render('<r:featured_pages:each date="today" limit="2" window="2 years"><r:title /> </r:featured_pages:each>').as('page plus_1_day ')
    end
  end
  
  describe "<r:featured_pages:each:if_first>" do
    before do
      save_pages
    end
    it "should expand contents if the page is the first in the collection" do
      page.should render('<r:featured_pages:each><r:if_first><r:title /> </r:if_first></r:featured_pages:each>').as('minus_1_week ')
    end
  end
  
  describe "<r:featured_pages:each:unless_first>" do
    before do
      save_pages
    end
    it "should expand contents if the page is not the first in the collection" do
      page.should render('<r:featured_pages:each><r:unless_first><r:title /> </r:unless_first></r:featured_pages:each>').as('page plus_1_day plus_2_weeks plus_2_months plus_2_years ')
    end
  end
end
