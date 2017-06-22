module ReportsHelper


  def meeting_duration(meeting)
  	begin
		  duration = (Time.parse(meeting.ends_at) - Time.parse(meeting.starts_at))
		  time_minutes = ((duration) / 60) % 60
		  time_hours =   duration / (60 * 60)
		  final_duration = format("%2dh %2dmins", time_hours,time_minutes)
  	rescue
      final_duration = nil
  	end
	  return final_duration
  end
end
