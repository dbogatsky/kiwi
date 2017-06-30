class GpsPosition < OrchardApiModel

	# Get Google place location 
	def self.getAllPosition(session, params)
		url = "https://acme-api.code10.ca:443/api/v1/gps_positions.json?per_page=1000&search[timestamp_gteq]="+DateTime.parse(params[:date]).beginning_of_day.utc.to_s+"&search[timestamp_lteq]="+DateTime.parse(params[:date]).end_of_day.utc.to_s+"&search[user_id_eq]="+params[:user].to_s
    uri = URI.parse(url)
    header = {'Content-Type' => 'application/json'}
    header = {'X-HTTP-Method-Override' => 'PUT'}
    header = {'Authorization' => 'Token token="secret_WDyL7RAzY3VGxhGoM7ne", app_key="app_ceBVJgFWSUYq5H9HtWWy"'}
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    
    request = Net::HTTP::Get.new(uri.request_uri, header)
    return self.setResponse(JSON.parse(http.request(request).body))
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
end
