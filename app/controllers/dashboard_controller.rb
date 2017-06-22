require 'open_weather'
class DashboardController < ApplicationController
  before_action :get_api_values, only: [:index]
  before_action :get_news, only: [:index]
  before_action :application_settings, only: [:index]

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
    # @accounts_cache = accounts_cache # DIS001 disabled for now

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

      if (wresponse["cod"] == 200)
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
      end
    else
      @weather = Hash[]
    end

    #
    #  Visit and last known location
    #
    if @gps_tracking == 'on' && ( can? :visits_gps_tracking, Account )
      entities = CompanyEntity.all(uid: RequestStore.store[:tenant], reload: true)
      @users_lastknown_position = users_gps_position
      company_coordinates
    end
  end

  def visits_lastknown
    @users_lastknown_position = users_gps_position
    render json: {success: true, user_gmap: @users_lastknown_position}
  end

  private

  def users_gps_position(time=60)
    search = {}

    search[:timestamp_gteq] = time.minutes.ago.utc
    search[:timestamp_lteq] = Time.now.utc

    users_gps_tracking_info = {}
    gps_positions = GpsPosition.all(params: {search: search, per_page: 300})

    gps_positions.each do | gps_position |
      unless users_gps_tracking_info.has_key? gps_position.user.id
        users_coordinate = {}
        users_coordinate[:user_firstname] = gps_position.user.try(:first_name)
        users_coordinate[:user_lastname] = gps_position.user.try(:last_name)
        users_coordinate[:latitude] = gps_position.lat
        users_coordinate[:longitude] = gps_position.lon
        users_coordinate[:timestamp] = gps_position.timestamp
        users_coordinate[:positionable_id] = gps_position.positionable_id
        users_coordinate[:positionable_type] = gps_position.positionable_type

        users_gps_tracking_info[gps_position.user.id] = users_coordinate

      else

        if Time.parse(gps_position.timestamp) > Time.parse(users_gps_tracking_info[gps_position.user.id][:timestamp])
          users_coordinate = {}
          users_coordinate[:user_firstname] = gps_position.user.try(:first_name)
          users_coordinate[:user_lastname] = gps_position.user.try(:last_name)
          users_coordinate[:latitude] = gps_position.lat
          users_coordinate[:longitude] = gps_position.lon
          users_coordinate[:timestamp] = gps_position.timestamp
          users_coordinate[:positionable_id] = gps_position.positionable_id
          users_coordinate[:positionable_type] = gps_position.positionable_type

          users_gps_tracking_info[gps_position.user.id] = users_coordinate
        end

      end
    end

    users_gps_tracking_array = []
    users_gps_tracking_info.each do |user_id, gps_tracking_info|
      users_gps_tracking_array << [gps_tracking_info[:latitude], gps_tracking_info[:longitude]].map(&:to_f) + [gps_tracking_info[:timestamp].in_time_zone.strftime("%Y-%m-%d %I:%M:%S %p")] + [gps_tracking_info[:user_firstname] + " " + gps_tracking_info[:user_lastname]]
    end

    users_gps_tracking_array
  end

  def company_coordinates

    company = Company.find(uid: RequestStore.store[:tenant])
    @company_marker_address = company.addresses.first
    @zoom_level = 5 #Default zoom level

    @company_coordinates = {}
    if company.addresses.present?
      if company.addresses.first.present? && (company.addresses.first.latitude.nil? || company.addresses.first.longitude.nil?)
        company_address = (
            company.addresses.first.street_address + ', ' +
            company.addresses.first.suite_number + ', ' +
            company.addresses.first.city + ', ' +
            company.addresses.first.region + ', ' +
            company.addresses.first.country
          )
        geocoder_coordinates = Geocoder.coordinates(company_address)

        @company_coordinates[:latitude] = geocoder_coordinates[0] if geocoder_coordinates.present?
        @company_coordinates[:longitude] = geocoder_coordinates[1] if geocoder_coordinates.present?

      elsif company.addresses.first.latitude.present? && company.addresses.first.longitude.present?
        @company_coordinates[:latitude] = company.addresses.first.latitude
        @company_coordinates[:longitude] = company.addresses.first.longitude
      end
    else
      #default central location (GB)
      @company_coordinates[:latitude] = "51.509865"
      @company_coordinates[:longitude] = "-0.118092"
      @zoom_level = 10 #Wide zoom level
    end

  end

  def get_api_values
    @email = current_user.email
    @appKey = APP_CONFIG['api_app_key']
    @token = session[:token]
  end

  def entity_branch(parent_id, entities, level)
    current_branch = {}
    entities.each do |entity|
      entity_parent_id = entity["parent"].as_json.present? ? entity["parent"].as_json["id"] : nil
      if entity_parent_id == parent_id

        current_branch = entity_branch(entity["id"], entities, level+1)
      end
    end
    current_branch
  end

  #  def generate_entities_table_recur(parent_id, entities, level)
  #    html = ''
  #    entities.each do |entity|
  #      entity_parent_id = entity["parent"].as_json.present? ? entity["parent"].as_json["id"] : nil
  #      if entity_parent_id == parent_id
  #        padding = level * 10
  #        html += content_tag(:ul, render('company/entity', entity: entity),
  #                  class: "table_head table_content level_#{level}", style: "padding-left: #{padding}px ")
  #        html += generate_entities_table_recur(entity["id"], entities, level+1)
  #      end
  #    end
  #    html
  #  end


end
