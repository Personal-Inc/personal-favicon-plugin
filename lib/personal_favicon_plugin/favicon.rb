require 'net/http'
require 'net/https'
require 'uri'
require 'open-uri'

class Favicon

		# Declaring get method

		def self.get(url)

			@main_url = url
			@main_url
		end

		# Get the page content from a URL

		private 

		def self.open_url(url)
			begin

				uri = URI.parse(url)

				if uri.scheme == "https"
					http = Net::HTTP.new(uri.host, uri.port)
					http.use_ssl = true
					http.verify_mode = OpenSSL::SSL::VERIFY_NONE

					request = Net::HTTP::Get.new(uri.request_uri)

					response = http.request(request)
					response.body
				else
					Net::HTTP.get(URI.parse(url))
				end		

			rescue SocketError => se
				puts "Got socket error: #{se}"
			end

		end

		# Send a GET request to the target and returns the HTTP response
		# as a Net::HTTPResponse object for image url

		private

		def self.open_img_url(image_url)

			begin

				image_url_https = URI.parse(image_url)

				if image_url_https.scheme == "https"
					http = Net::HTTP.new(image_url_https.host, image_url_https.port)
					http.use_ssl = true
					http.verify_mode = OpenSSL::SSL::VERIFY_NONE

					image_url_response = http.request(Net::HTTP::Get.new(image_url_https.request_uri))
					image_url_response
				else
					image_url_response = Net::HTTP.get_response(URI.parse(image_url))
		
					image_url_response
				end
			rescue SocketError => se
				puts "Got socket error: #{se}"
			end

		end

		# Get the response code for the favicon url

		private

		def self.response_code(img_url_respon)

			code  = Integer(img_url_respon.code)
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
			base_uri = URI.parse(address)
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

			page_content = open_url(base_url)
			
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
				puts "Check the socket error"
			end
			 
		end


		# Obtaining the favicon

		private

		def self.get_favicon

			if check_favicon == true
				parse_html
			else

				imgur = open_img_url(base_favicon)

				if imgur != nil
					imgurcd = response_code(imgur)

					if(imgurcd >= 200 && imgurcd <= 400)
						base_favicon
					else
						default_favicon = "default favicon?!!"
						default_favicon
					end
				else
					puts "Check the socket error"
				end
				
			end

		end

		# returning favicon.ico 

		private

		def self.show_favicon

			get_favicon

		end

		# processing the image

		def self.process_favicon_image

			#send_data data,:filename => "favicon.ico", :type => "image/ico", :disposition => "inline"

			#contentfavicon = show_favicon
			#data = open("#{get_favicon}","rb")
			#data

			contentfavicon = get_favicon
			uri_content_favicon = URI.parse(contentfavicon)
			exp1 = contentfavicon.split(base_url.chomp("/"))
			

			if(uri_content_favicon.scheme == "https")
				exp = contentfavicon.split("https://")
				exp2 = exp[1].split("/")

				Net::HTTP.start(exp2[0], :use_ssl => true, :verify_mode => OpenSSL::SSL::VERIFY_NONE) { |http|
				resp = http.get(exp1[1])
				File.open("favicon.ico","rb") { |file|
					file.read(resp.body)
					}
				}


			else
				exp = contentfavicon.split("http://")
				exp2 = exp[1].split("/")

				Net::HTTP.start(exp2[0]) { |http|
				resp = http.get(exp1[1])
				File.open("favicon.ico","rb") { |file|
					file.read(resp.body)
					}
				}
			end



		end



		    
end
		


