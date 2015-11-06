class DashboardController < ApplicationController

  def index

    # Generate greeting message in the dashboard
    # to get the current time zone of t is t.zone
    current_time = Time.current
    current_time_zone = "UTC" # Stays UTC for now.  Get the time zone from settings later.

    if ( current_time.in_time_zone(current_time_zone).hour < 12 ) # Morning - Before 12:00
      greeting = 'Good morning '
    elsif ( current_time.in_time_zone(current_time_zone).hour > 11 && current_time.in_time_zone(current_time_zone).hour < 18 ) # Afternoon - Between 11:00 and 18:00
      greeting = 'Good afternoon '
    elsif ( current_time.in_time_zone(current_time_zone).hour > 17 ) # Evening - After 17:00
      greeting = 'Good evening '
    else
      greeting = 'Hello '
    end

    @GreetingMessage = greeting + (current_user.first_name || "")

  end


  private

    # More info about the Open Weather Map --> http://openweathermap.org/api
    # http://api.openweathermap.org/data/2.5/weather?q=Vancouver,CA&APPID=59972cbdeb7c9f8000bcd04dac2aaccd
    def getWeatherInfo
      uri = URI.parse("http://api.openweathermap.org/data/2.5/weather")

      # Shortcut
      #response = Net::HTTP.post_form(uri, {"q" => "Vancouver,CA", "APPID" => APP_CONFIG['open_weather_map']})

      # Full control
      http = Net::HTTP.new(uri.host, uri.port)

      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data({"q" => "Vancouver,CA", "APPID" => APP_CONFIG['open_weather_map']})

      response = http.request(request)
      render :json => response.body

    end


end
