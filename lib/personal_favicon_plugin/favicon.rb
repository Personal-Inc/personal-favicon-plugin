class Favicon

	#attr_accessor :@main_url

		# Declaring initialize method
		def self.get(url)
			@main_url = url
			@main_url
		end


		#def create(url)
			#@main_url = params[:url]
		#	@main_url = url
		#	@main_url
		#end

		# Get the page content from a URL

		private 

		def self.open(url)

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

		end

		# Send a GET request to the target and returns the HTTP response
		# as a Net::HTTPResponse object

		private

		def self.open_img_url(image_url)
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
		end

		# Get the response code for the favicon url

		private

		def self.response_code(img_url_respon)
			code  = Integer(img_url_respon.code)
			code
		end

		# check if it is possible to retreive favicon 
		# by appending favicon.ico and then retrieving

		private

		def self.check_favicon
		
			begin 

				imgur = open_img_url("#{@main_url}/favicon.ico")
				imgurcd = response_code(imgur)
				
				value = true

				if imgurcd >=200 && imgurcd <= 400
					#puts "image found -> code: #{imgurcd}"
					value = true
				else
					#puts "image not found"
					value = false
				end
			rescue Errno::ECONNRESET => e
				#puts "You cannot retreive the favicon by base url"
				value = false
			end
			#puts value
			value
		end

		# parsing and returning the content of index 

		private

		def self.parse_html

			page_content = open(@main_url)
			

			regxp = /link rel\=.*icon.*/

			slice_content = page_content.slice(regxp)


			if slice_content != nil
				exp = slice_content.split("href=")
				exp1 = exp[1].split('"')
				exp2 = exp1[1].split("http:")


				if exp2[0] != ""
					@final_url = @main_url.chomp("/") + exp1[1]
					return @final_url
				else
					@final_url = exp1[1]
					return @final_url
				end
			end

			
			##### The following is just a exact extract from discover.com for favicon
			#### <link rel="icon" href="/images/favicon.ico" type="image/x-icon" />
			 
		end

		# Obtaining the favicon
		private

		def self.get_favicon

			if check_favicon == true
				if @main_url.end_with? "/"
					#puts @main_url.chomp("/") + "/favicon.ico"
					@main_url.chomp("/") + "/favicon.ico"
				else
					#puts @main_url + "/favicon.ico"
					@main_url + "/favicon.ico"
				end
			else
				#puts parse_html
				parse_html
			end
		end

		def self.show_favicon
			 #redirect_to get_favicon
			 #puts get_favicon
			 get_favicon
		end

end
