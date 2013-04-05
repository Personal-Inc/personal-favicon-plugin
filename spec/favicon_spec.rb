require 'spec_helper'

describe Favicon do
  it 'should get the url' do
    Favicon.set_url=("https://www.google.com/")
    Favicon.get_url.should == "https://www.google.com/"
  end

  it 'should check if the input is uri' do
  	Favicon.check_uri?("skdsjdsjkdjd").should == false
  end

  it 'should return a base url with uri scheme and host' do
  	Favicon.set_url=("https://www.discover.com/home-loans/?ICMPGN=HDR_CS_HELP_DHL_TXT_HP")
    Favicon.get_url
  	Favicon.base_url.should == "https://www.discover.com"
  end

  it 'checks the regular expressions, pattern matching and extracting the needed information' do
  	Favicon.set_url=("https://www.discover.com/")
    Favicon.get_url
  	Favicon.base_url
  	Favicon.parse_html.should == "https://www.discover.com/images/favicon.ico"
  end

   it 'checks the regular expressions, pattern matching and extracting the needed information' do
    Favicon.set_url=("http://www.chalmers.se/sv/Sidor/default.aspx")
    Favicon.get_url
    Favicon.parse_html.should == "http://www.chalmers.se/_layouts/Chalmers.Core.UI/Images/favicon.ico"
  end
 
end