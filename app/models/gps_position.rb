class GpsPosition < OrchardApiModel

	# Get Google place location 
	def self.getAllPosition(session, params)
		url = "https://acme-api.code10.ca:443/api/v1/gps_positions.json?per_page=1000&search[timestamp_gteq]="+DateTime.parse(params[:date]).beginning_of_day.to_s+"&search[timestamp_lteq]="+DateTime.parse(params[:date]).end_of_day.to_s+"&search[user_id_eq]="+params[:user].to_s
    uri = URI.parse(url)
    header = {'Content-Type' => 'application/json'}
    header = {'X-HTTP-Method-Override' => 'PUT'}
    header = {'Authorization' => 'Token token="'+session+'", app_key="'+APP_CONFIG["api_app_key"]+'"'}
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(uri.request_uri, header)
    result = http.request(request).body
    return result && result.length >= 2 ? self.setResponse(JSON.parse(result)) : nil
	end

	def self.setResponse(data)

		if data['gps_positions'].length > 0
			result = {}
			geometry = {}
			properties = {}
			geometry['type'] = 'MultiPoint'
			# properties['title'] = data['gps_positions'][0]['type']
			# properties['path_options'] = {:color => "red"}
			result['type'] = "Feature"
			coordinates = []
			time = []
			# speed = []
			# altitude = []
			# heading = []
			# horizontal_accuracy = []
			# vertical_accuracy = []
			data['gps_positions'].each_with_index do |d, i|
				coordinates.push([d['lon'].to_f, d['lat'].to_f])
				time.push(d['timestamp'].to_time.to_i*1000)
				# speed.push(80)
				# altitude.push(45+i)
				# heading.push(0)
				# horizontal_accuracy.push(50+i)
				# vertical_accuracy.push(0)
			end
			properties['time'] = time
			# properties['speed'] = speed
			# properties['altitude'] = altitude
			# properties['heading'] = heading
			# properties['horizontal_accuracy'] = horizontal_accuracy
			# properties['vertical_accuracy'] = vertical_accuracy
			# properties['raw'] = []
			geometry['coordinates'] = coordinates
			result['geometry'] = geometry
			result['properties'] = properties
			return result.to_json
		else
			return nil
		end
	end


	def self.setMarkerImage(userImg, mrkrImgPath, defaultUserImg)
		require 'rmagick'
		require 'open-uri'
		bg= Magick::Image.new(40,64){self.background_color = 'Transparent'}
		if userImg.nil? || userImg == '/avatars/web/missing.png'
			userImg= Magick::Image.read(defaultUserImg).first
	  else
	  	r = open(userImg)
	    bytes = r.read
	    userImg = Magick::Image.from_blob(bytes).first
	  end
		markerImg = Magick::Image.read(mrkrImgPath).first

		source = userImg.resize_to_fill(26,26).quantize(256).contrast(true)
		jj = bg.composite(source, 7, 7, Magick::OverCompositeOp)
		oo = jj.composite(markerImg, 0, 0, Magick::OverCompositeOp)
		oo.format = "png"
		return oo.to_blob
		# oo.write('qq.png')
	end
end
