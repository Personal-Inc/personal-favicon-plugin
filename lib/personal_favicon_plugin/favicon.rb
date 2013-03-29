require 'net/http'
require 'net/https'
require 'uri'
require 'faraday'
require 'whois'

class Favicon

		# Declaring get method

		private

		def self.get(url)

			@main_url = url
		    return @main_url

		end


		# check if the input is URI?

		private 

		def self.uri?(string)

  			uri = URI.parse(string)
  			
  			%w( http https ).include?(uri.scheme)

			rescue URI::BadURIError
  				return false
			rescue URI::InvalidURIError
 				return false

		end


		# Using Faraday for connection

		private

		def self.connection(fara_url)

			#:ssl => { :verify_mode => OpenSSL::SSL::VERIFY_NONE}
			
				conn_opt = {:url => fara_url,:max_redirects => 2}
				conn = Faraday.new (conn_opt) do |faraday|
					faraday.request :url_encoded
					faraday.response :logger
					faraday.adapter Faraday.default_adapter
				end
			
		end

		# Get URL response

		private 

		def self.url_response(url)
			begin
				conn = connection(url)
				url_resp = conn.get "#{url}"
				return url_resp
		
			rescue SocketError => se

			 	return "Got socket error: #{se}"
			 	
			end
		end

		# Get the page content from a URL

		private 

		def self.url_body(url)
			begin

				response = url_response(url)
				return response.body		

			rescue SocketError => se
				return "Got socket error: #{se}"
			end

		end		


		# retrieve favicon by appending favicon.ico and then retrieving

		private

		def self.base_favicon

			if base_url.end_with? "/"
				return base_url.chomp("/") + "/favicon.ico"
			else
				return base_url + "/favicon.ico"
			end

		end

		# check the domain and its availability using
		# WHOIS client and parser

		private

		def self.check_domain_availability?(url)
			r = Whois.whois(url)
			return r.registered?
		end


		# check if it is possible to retreive favicon 
		# by parsing the html at first

		private

		def self.check_favicon?
		
			begin 
				value = true

				if parse_html != nil
					value = true
				else
					value = false
				end
			rescue Errno::ECONNRESET => e
				value = false
			end
			return value

		end


		# parsing the url to get the base url 

		private

		def self.base_url

			address = @main_url
			base_uri = connection(address)
			return "#{base_uri.scheme}://#{base_uri.host}"

		end

		# splitting the content for favicon 

		private

		def self.sliced_content_split(content)

			exp = content.split("href=")
			exp1 = exp[1].split('"')
			exp2 = exp1[1].split("http:")

			if exp2[0] != ""
				@final_url = base_url.chomp("/") + exp1[1]
				return @final_url
			else
				@final_url = exp1[1]
				return @final_url
			end
		end


		# check if content of url page contains favicon string/name or not? before parsing it

		def self.contain_favicon_string?

			regxpic = /link rel\=.icon.*/
		    regxpshic = /link rel\=.shortcut icon.*/

			page_content = url_body(base_url)

			if page_content.match(regxpic) || page_content.match(regxpshic)
				return true
			else
				return false
			end

		end




		# parsing and returning the content of index 

		private

		def self.parse_html

			if contain_favicon_string? == true
				page_content = url_body(base_url)
			else
				page_content = url_body(@main_url)
			end

			
			if page_content != nil

				regxpic = /link rel\=.icon.*/
				regxpshic = /link rel\=.shortcut icon.*/


				slice_content = page_content.slice(regxpic)


				if slice_content != nil
					return sliced_content_split(slice_content) 

				elsif slice_content == nil
					slice_content = page_content.slice(regxpshic)

					if slice_content != nil
						return sliced_content_split(slice_content)
					else 
						return nil
					end

				else
					return nil
				end
			else
				return "Check the socket error"
			end
			 
		end


		# Obtaining the favicon

		private

		def self.get_favicon


			if check_favicon? == true
				parse_html
			else

				base_favicon					
			end

		end

		# returning favicon.ico 

		private

		def self.show_favicon

			get_favicon

		end

		# processing the image

		def self.favicon_image_binary(url)
			
			exp1 = url.split("www.")
			exp2 = exp1[1].split("/")

			if uri?("#{get(url)}") != false && check_domain_availability?("#{exp2[0]}") != false
				contentfavicon = show_favicon
				fav_image = url_body(contentfavicon)

				if fav_image.empty?
					personal_favicon_binary = url_body("https://www.personal.com/favicon.ico")
					return personal_favicon_binary
					
				else
					return fav_image
				end 
			else
				personal_favicon_binary = url_body("https://www.personal.com/favicon.ico")
				return personal_favicon_binary
			end
							

		end


end


