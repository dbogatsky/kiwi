require 'open_weather'
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

    #country and city should be loaded from user profile settings    
    wcity = "Vancouver"
    wcountry = "CA"

    wapi_options = { units: "metric", APPID: APP_CONFIG['open_weather_map'] }
    wresponse = OpenWeather::Current.city( wcity + "," + wcountry , wapi_options)
    
    @weather = Hash.new
    @weather["city"] = wcity
    @weather['country'] = wcountry
    @weather['condition'] = wresponse['weather'][0]["main"]
    @weather['temp'] = wresponse["main"]["temp"].ceil
    @weather['temp_max'] = wresponse["main"]["temp_max"].ceil
    @weather['wind'] = wresponse["wind"]["speed"].ceil
         
    if ( @weather['condition'] == "Clouds" )
      @weather['icon'] = "wi-cloudy"
    elsif ( @weather['condition'] == "Rain" ) 
      @weather['icon'] = "wi-rain"  
    elsif ( @weather['condition'] == "Drizzle" )
      @weather['icon'] = "wi-sprinkle"  
    elsif ( @weather['condition'] == "Thunderstorm" )
      @weather['icon'] = "wi-rain"  
    elsif ( @weather['condition'] == "Snow" )
      @weather['icon'] = " wi-snow"  
    elsif ( @weather['condition'] == "Extreme" ) 
      @weather['icon'] = "wi-tornado"  
    else
      @weather['icon'] = "wi-day-sunny"
    end

  end

end
