require 'net/http'
require 'net/https'
require 'uri'
require 'open-uri'
require 'faraday'

class Favicon

		# Declaring get method

		private

		def self.get(url)

			@main_url = url
			@main_url
		end


		# Using Faraday for connection

		private

		def self.connection(fara_url)
			
				conn_opt = {:url => fara_url, :ssl => { :verify_mode => OpenSSL::SSL::VERIFY_NONE},:max_redirects => 2}
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
		#rescue Errno::ETIMEDOUT
			 	return "Got socket error: #{se}"
			 	#puts "Got TIMEDOUT Error"
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
		

		# Get the response code for the favicon url

		private

		def self.response_code(img_url_respon)

			code  = Integer(img_url_respon.status)
			code

		end


		# retrieve favicon by appending favicon.ico and then retrieving

		private

		def self.base_favicon

			if base_url.end_with? "/"
				base_url.chomp("/") + "/favicon.ico"
			else
				base_url + "/favicon.ico"
			end

		end


		# check if it is possible to retreive favicon 
		# by parsing the html at first

		private

		def self.check_favicon
		
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
			value

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


		# parsing and returning the content of index 

		private

		def self.parse_html

			page_content = url_body(base_url)
			
			if page_content != nil

				regxpic = /link rel\=.icon.*/
				regxpshic = /link rel\=.shortcut icon.*/


				slice_content = page_content.slice(regxpic)


				if slice_content != nil
					sliced_content_split(slice_content)

				elsif slice_content == nil
					slice_content = page_content.slice(regxpshic)

					if slice_content != nil
						sliced_content_split(slice_content)
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

			if check_favicon == true
				parse_html
			else

				imgur = url_response(base_favicon)

				if imgur != nil
					imgurcd = response_code(imgur)

					if(imgurcd >= 200 && imgurcd <= 400)
						base_favicon
					else
						default_favicon = "default favicon?!!"
						default_favicon
					end
				else
					return "Check the socket error"
				end
				
			end

		end

		# returning favicon.ico 

		private

		def self.show_favicon

			get_favicon

		end

		# processing the image

		def self.favicon_image_binary(url)

			get(url)
			contentfavicon = show_favicon
			fav_image = url_body(contentfavicon)

			if fav_image.empty?
				personal_favicon_binary = url_body("https://www.personal.com/favicon.ico")
				return personal_favicon_binary
				
			else
				return fav_image
			end 
							

		end


		    
end





