require 'open_weather'
class DashboardController < ApplicationController
  before_action :get_api_values, only: [:index]
  before_action :get_news, only: [:index]

  def index
    #
    # schedule widget
    #
    user_ids = Array[]
    user_ids.push(current_user.id) # push any additional users

    team_user_ids = user_ids
    current_user_roles = current_user.roles.collect { |r| r.name }
    if current_user_roles.include?("Entity Admin") || current_user_roles.include?("Admin")
      users = User.all(uid: session[:user_id])
      team_user_ids = users.collect { |u| u.id }
    end

    # get the current date
    @current_date = Time.current.in_time_zone(current_user.time_zone).strftime('%Y-%m-%d')

    #
    # Meetings for the current date
    #
    search = Hash[]
    search[:type_eq] = 'ConversationItems::Meeting'
    search[:starts_at_gteq] = convert_datetime_to_utc(current_user.time_zone, @current_date, '00:00:00')
    search[:starts_at_lteq] = convert_datetime_to_utc(current_user.time_zone, @current_date, '23:59:59')

    @meetings = ConversationItemSearch.all(params: { user_ids: user_ids, search: search })

    quote_search = {}
    quote_search[:type_eq] = 'ConversationItems::Quote'
    quote_search[:status_eq] = 'Open'
    @quotes = ConversationItemSearch.all(params: { user_ids: team_user_ids, search: quote_search })

    #
    # Account feed of last 24 hours
    #
    search = Hash[]
    @current_date = Time.current.in_time_zone(current_user.time_zone).strftime('%Y-%m-%d')
    @current_time = Time.current.in_time_zone(current_user.time_zone).strftime('%H:%M:%S')
    @yesterday_date = Time.current.in_time_zone(current_user.time_zone).yesterday.strftime('%Y-%m-%d')
    @yesterday_time = Time.current.in_time_zone(current_user.time_zone).yesterday.strftime('%H:%M:%S')
    search[:updated_at_lteq] = convert_datetime_to_utc(current_user.time_zone, @current_date, @current_time)
    search[:updated_at_gteq] = convert_datetime_to_utc(current_user.time_zone, @yesterday_date, @yesterday_time)
    @accounts = Account.all(params: { search: search })
    @accounts = @accounts.sort_by { |account| account.updated_at }.reverse

    #
    # quick stats widget
    #
    current_time = Time.current
    current_time_zone = current_user.time_zone

    if (current_time.in_time_zone(current_time_zone).hour < 12) # Morning - Before 12:00
      greeting = 'Good morning '
    elsif (current_time.in_time_zone(current_time_zone).hour > 11 && current_time.in_time_zone(current_time_zone).hour < 18) # Afternoon - Between 11:00 and 18:00
      greeting = 'Good afternoon '
    elsif (current_time.in_time_zone(current_time_zone).hour > 17) # Evening - After 17:00
      greeting = 'Good evening '
    else
      greeting = 'Hello '
    end

    @greeting_message = greeting + (current_user.first_name || '')

    @quick_stats = QuickStats.find

    #
    # weather widget
    #
    if current_user.addresses.present?
      wcity = current_user.addresses.last.city
      wcountry = current_user.addresses.last.country

      wapi_options = { units: 'metric', APPID: APP_CONFIG['open_weather_map'] }
      wresponse = OpenWeather::Current.city(wcity + ',' + wcountry, wapi_options)

      @weather = Hash[]
      @weather['city'] = wcity
      @weather['country'] = wcountry
      @weather['condition'] = wresponse['weather'][0]['main']
      @weather['temp'] = wresponse['main']['temp'].ceil
      @weather['temp_max'] = wresponse['main']['temp_max'].ceil
      @weather['wind'] = wresponse['wind']['speed'].ceil

      if (@weather['condition'] == 'Clouds')
        @weather['icon'] = 'wi-cloudy'
      elsif (@weather['condition'] == 'Rain')
        @weather['icon'] = 'wi-rain'
      elsif (@weather['condition'] == 'Drizzle')
        @weather['icon'] = 'wi-sprinkle'
      elsif (@weather['condition'] == 'Thunderstorm')
        @weather['icon'] = 'wi-rain'
      elsif (@weather['condition'] == 'Snow')
        @weather['icon'] = ' wi-snow'
      elsif (@weather['condition'] == 'Extreme')
        @weather['icon'] = 'wi-tornado'
      else
        @weather['icon'] = 'wi-day-sunny'
      end
    else
      @weather = Hash[]
    end
  end

  private

  def get_api_values
    @email = current_user.email
    @appKey = APP_CONFIG['api_app_key']
    @token = session[:token]
  end
end
