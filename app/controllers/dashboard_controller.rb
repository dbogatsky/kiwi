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

end
