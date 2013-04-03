require 'uri'
require 'faraday'
require 'whois'

class Favicon

		# Declaring setter method

		private

		def self.set_url=(url)

			@main_url = url

		end

		#declaring getter method

		def self.get_url
			@main_url
		end

		# check if the input is URI?

		private 

		def self.check_uri?(string)

			begin

	  			uri = URI.parse(string)	  			
	  			%w( http https ).include?(uri.scheme)

			rescue StandardError
  				return false
  			end

		end


		# Using Faraday for connection


		def self.connection(fara_url)

			conn_opt = {:url => fara_url,:ssl => { :verify_mode => 0}}
			Faraday.new(conn_opt) do |faraday|
				faraday.request :url_encoded
				faraday.response :logger
				faraday.adapter Faraday.default_adapter
			end
			
		end


		# Get URL response


		def self.url_response(url)

			conn = connection(url)
			url_resp = conn.get "#{url}"
			return url_resp
		
		end

		# Get the page content from a URL


		def self.url_body(url)

			response = url_response(url)
			return response.body		

		end		
	

		# check if it is possible to retreive favicon 
		# by parsing the html at first


		def self.check_favicon?
		
			begin 
				value = true

				if parse_html !=nil
					value = true
				else
					value = false
				end
			rescue Errno::ECONNRESET 
				value = false
			end
			return value

		end


		# parsing the url to get the base url 


		def self.base_url

			address = get_url
			base_uri = connection(address)
			return "#{base_uri.scheme}://#{base_uri.host}"

		end

		# splitting the content for favicon 


		def self.sliced_content_split(content)

			link_content = content.split("href=")
			href_content = link_content[1].split('"')
			favicon_path = href_content[1].split("http:")			

			if favicon_path[0] != ""
				final_url = base_url.chomp("/") + href_content[1]
				return final_url
			else
				final_url = href_content[1]
				return final_url
			end
		end
	

		# parsing and returning the content of index 


		def self.parse_html

			regxpic = /link rel\=.icon.*/
		    regxpshic = /link rel\=.shortcut icon.*/

		    page_content = url_body(base_url)

			if page_content.match(regxpic) 
				slice_content = page_content.slice(regxpic)
				return sliced_content_split(slice_content)
			elsif page_content.match(regxpshic)
				slice_content = page_content.slice(regxpshic)
				return sliced_content_split(slice_content)
			else
				page_content = url_body(get_url)
				if page_content.match(regxpic)
					slice_content = page_content.slice(regxpic)
					return sliced_content_split(slice_content)
				elsif page_content.match(regxpshic)
					slice_content = page_content.slice(regxpshic)
					return sliced_content_split(slice_content)
				else
					return nil
				end
			end

			
		end


		# Obtaining the favicon


		def self.get_favicon

			check_favicon? ? parse_html : base_url + "/favicon.ico"

		end


		# processing the image

		public

		def self.favicon_image_binary(url)
			
			Favicon.set_url=(url) 

			begin 

				protocol_domain = url.split("www.")
				domain = protocol_domain[1].split("/")
				check_registration = Whois.whois("#{domain[0]}")

				raise StandardError if check_registration.registered? != true

				contentfavicon = get_favicon
				fav_image = url_body(contentfavicon)

				raise StandardError if fav_image.empty?

				return fav_image

			rescue StandardError
				personal_favicon_binary = url_body("https://www.personal.com/favicon.ico")
				return personal_favicon_binary
			end
							

		 end


end
