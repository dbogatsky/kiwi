class ReportsController < ApplicationController
  def meeting_report
  end

  def meeting_report_result
    user_ids = Array.new
    user_ids = params[:users]
    search = Hash.new
    search[:type_eq]="ConversationItems::Meeting"
    s_date = Chronic.parse(params[:search][:date_gteq]).in_time_zone(current_user.time_zone).strftime("%Y-%m-%d")
    e_date = Chronic.parse(params[:search][:date_lteq]).in_time_zone(current_user.time_zone).strftime("%Y-%m-%d")
    search[:starts_at_gteq]="#{s_date} 00:00:00"
    search[:starts_at_lteq]="#{e_date} 23:59:59"
    @meetings = ConversationItemSearch.all(params: {user_ids: user_ids, search: search})
    @total_meetings = @meetings.count
    @total_check_in = 0
    @total_check_out = 0
    @meeting_time_in_second = 0
    @average_time_for_meeting = format("%02d:%02d", 00, 00)
    @meeting_duration = 0
    longest_duration = 0
    shortest_duration = 0
    @longest_meeting_time = format("%02d:%02d", 00, 00)
    @shortest_meeting_time = format("%02d:%02d", 00, 00)
    if @meetings.present?
	    @meetings.each do |meeting|
	    	@total_check_in = @total_check_in + meeting.check_ins.count
	    	@total_check_out = @total_check_out + meeting.check_outs.count
	    	starts_at = Chronic.parse(meeting.starts_at).in_time_zone(current_user.time_zone).to_s
	    	ends_at =  Chronic.parse(meeting.ends_at).in_time_zone(current_user.time_zone).to_s
        @meeting_time_in_second =  @meeting_time_in_second + (Time.parse(ends_at) - Time.parse(starts_at))
	      meeting_duration = (Time.parse(ends_at) - Time.parse(starts_at))
	      longest_duration   =  meeting_duration if longest_duration < meeting_duration
	      shortest_duration  =  meeting_duration if shortest_duration > meeting_duration
	    end
      minutes = ((@meeting_time_in_second / @total_meetings) / 60) % 60
      hours = (@meeting_time_in_second / @total_meetings) / (60 * 60)
      @average_time_for_meeting = format("%02d:%02d", hours, minutes)

      longest_meeting_time_minutes = ((longest_duration) / 60) % 60
      longest_meeting_time_hours = (longest_duration) / (60 * 60)
      @longest_meeting_time = format("%02d:%02d", longest_meeting_time_hours, longest_meeting_time_minutes)

	    shortest_meeting_time_minutes = ((shortest_duration) / 60) % 60
      shortest_meeting_time_hours = (shortest_duration) / (60 * 60)
      @shortest_meeting_time = format("%02d:%02d", shortest_meeting_time_hours, shortest_meeting_time_minutes)
	  end
  end
end
