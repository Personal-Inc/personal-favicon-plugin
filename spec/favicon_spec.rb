require 'spec_helper'

describe Favicon do
  it 'should get the url' do
    Favicon.get("https://www.google.com/").should == "https://www.google.com/"
  end

  it 'should check if the input is uri' do
  	Favicon.uri?("skdsjdsjkdjd").should == false
  end

  it 'should return a url with favicon appended' do
  	Favicon.get("https://www.google.com/")
  	Favicon.base_url
  	Favicon.base_favicon.should == "https://www.google.com/favicon.ico"
  end

  it 'checks the pattern matching inside a content' do
  	Favicon.get("https://www.discover.com/")
  	Favicon.base_url
  	Favicon.contain_favicon_string?.should == true
  end

   it 'checks the pattern matching inside a content' do
  	Favicon.get("http://www.chalmers.se/en/Pages/default.aspx")
  	Favicon.base_url
  	Favicon.contain_favicon_string?.should == false
  end

  it 'checks the regular expressions and extracting the needed information' do
  	Favicon.get("https://www.discover.com/")
  	Favicon.base_url
  	Favicon.parse_html.should == "https://www.discover.com/images/favicon.ico"
  end

  
 
end