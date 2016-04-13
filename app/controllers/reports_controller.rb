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
    no_of_day = ((e_date.to_date-s_date.to_date).to_i)+1
    search[:starts_at_gteq]="#{s_date} 00:00:00"
    search[:starts_at_lteq]="#{e_date} 23:59:59"
    @meetings = ConversationItemSearch.all(params: {user_ids: user_ids, search: search})

    day_of_Week_bar_chart_data(@meetings)
    time_of_day_bar_chart_data(@meetings)
    meetings_by_account_status_data(@meetings)

    @total_meetings = @meetings.count
    @meetings_per_daye = (@total_meetings.to_f/no_of_day.to_f).ceil
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
      minutes = ((@meeting_time_in_second / @total_meetings) / 60) % 60 rescue 0
      hours = (@meeting_time_in_second / @total_meetings) / (60 * 60)  rescue 0
      @average_time_for_meeting = format("%02dh %02dmins", hours, minutes)

      longest_meeting_time_minutes = ((longest_duration) / 60) % 60  rescue 0
      longest_meeting_time_hours = (longest_duration) / (60 * 60)  rescue 0
      @longest_meeting_time = format("%02dh %02dmins", longest_meeting_time_hours, longest_meeting_time_minutes)

	    shortest_meeting_time_minutes = ((shortest_duration) / 60) % 60  rescue 0
      shortest_meeting_time_hours = (shortest_duration) / (60 * 60)  rescue 0
      @shortest_meeting_time = format("%02dh %02dmins", shortest_meeting_time_hours, shortest_meeting_time_minutes)
	  end
  end

  def check_in_check_out
    @meeting = ConversationItem.find(params[:id], params: {conversation_id: params[:ci_id]})
    @success = true
  rescue
    @success = false
  end


 private

  def day_of_Week_bar_chart_data(meetings)
    su, mo, t, w, th, f, st = 0, 0, 0, 0, 0, 0, 0
    if meetings.present?
      meetings.each do |m|
        if m.starts_at.present?
          s_d = m.starts_at
           day = Chronic.parse(s_d).in_time_zone(current_user.time_zone).strftime("%a")
          if day == 'Sun'
             su=su+1
          elsif day == 'Mon'
             mo=mo+1
          elsif day == 'Tue'
             t=t+1
          elsif day == 'Wed'
             w=w+1
          elsif day == 'Thu'
             th=th+1
          elsif day == 'Fri'
             f=f+1
          elsif day == 'Sat'
             st=st+1
          end
        end
      end
    end
    @data = {y: 'Mon', a: mo},
           {y: 'Tue', a: t},
           {y: 'Wed', a: w},
           {y: 'Thu', a: th},
           {y: 'Fri', a: f},
           {y: 'Sat', a: st},
           {y: 'Sun', a: su}
    @data = @data.to_json
  end

  def meetings_by_account_status_data(meetings)
    statuses = {}
    @color = []
    AccountStatus.find(:all, reload: true).each_with_index do |status, index|
      statuses[status.name.to_sym] = 0
      @color << status.color
    end
    if meetings.present?
      meetings.each do |m|
        account_id = m.account_id
        account = Account.find(account_id)
        account_status = account.status.name
        statuses.each do |k, v|
          if account_status.to_sym == k
            statuses[k] = statuses[k] + 1
          end
        end
      end
    end
    arr = []
    statuses.each do |k, v|
      v = (v/meetings.size)*100 rescue 0
      arr << {label: k.to_s, value: v}
    end
    @account_data = arr.to_json
  end

  def time_of_day_bar_chart_data(meetings)
    t1, t2, t3, t4, t5, t6, t7, t8, t9, t10, t11, t12, t13, t14, t15, t16, t17, t18, t19, t20, t21, t22, t23, t24 = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    if meetings.present?
      meetings.each do |m|
        if m.starts_at.present?
           time = Chronic.parse(m.starts_at).in_time_zone(current_user.time_zone).hour
           if time == 0
            t1=t1+1
           elsif time == 1
            t2=t2+1
           elsif time == 2
            t3=t3+1
           elsif time == 3
            t4=t4+1
           elsif time == 4
            t5=t5+1
           elsif time == 5
            t6=t6+1
           elsif time == 6
            t7=t7+1
           elsif time == 7
            t8=t8+1
           elsif time == 8
            t9=t9+1
           elsif time == 9
            t10=t10+1
           elsif time == 10
            t11=t11+1
           elsif time == 11
            t12=t12+1
           elsif time == 12
            t13=t13+1
           elsif time == 13
            t14=t14+1
           elsif time == 14
            t15=t15+1
           elsif time == 15
            t16=t16+1
           elsif time == 16
            t17=t17+1
           elsif time == 17
            t18=t18+1
           elsif time == 18
            t19=t19+1
           elsif time == 19
            t20=t20+1
           elsif time == 20
            t21=t21+1
           elsif time == 21
            t22=t22+1
           elsif time == 22
            t23=t23+1
           elsif time == 22
            t24=t24+1
           end
        end
      end
    end

    @time_data = {y: '00:00 AM', a: t1},
           {y: '01:00 AM', a: t2},
           {y: '02:00 AM', a: t3},
           {y: '03:00 AM', a: t4},
           {y: '04:00 AM', a: t5},
           {y: '05:00 AM', a: t6},
           {y: '06:00 AM', a: t7},
           {y: '07:00 AM', a: t8},
           {y: '08:00 AM', a: t9},
           {y: '09:00 AM', a: t10},
           {y: '10:00 AM', a: t11},
           {y: '11:00 AM', a: t12},
           {y: '12:00 PM', a: t13},
           {y: '01:00 PM', a: t14},
           {y: '02:00 PM', a: t15},
           {y: '03:00 PM', a: t16},
           {y: '04:00 PM', a: t17},
           {y: '05:00 PM', a: t18},
           {y: '06:00 PM', a: t19},
           {y: '07:00 PM', a: t20},
           {y: '08:00 PM', a: t21},
           {y: '09:00 PM', a: t22},
           {y: '10:00 PM', a: t23},
           {y: '11:00 PM', a: t24}
    @time_data = @time_data.to_json
  end
end
