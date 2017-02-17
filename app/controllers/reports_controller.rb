class ReportsController < ApplicationController
  def meeting_report
    @users = User.all(uid: session[:user_id], reload: true)
    get_account_display_setting
  end

  def activity_report
    @users = User.all(uid: session[:user_id], reload: true)
  end

  def sales_report
    @users = User.all(uid: session[:user_id], reload: true)
  end

  def meeting_report_result
    if current_user.roles.last.try(:name) == 'User'
      user_ids = [current_user.id]
    else
      if params[:users].present?
        if params[:users].include? 'all'
          user_ids = User.all(uid: session[:user_id], reload: true).map(&:id)
        else
          user_ids = params[:users]
        end
      else
        user_ids = [current_user.id]
      end
    end
    search = Hash[]
    search[:type_eq] = 'ConversationItems::Meeting'
    s_date = Chronic.parse(params[:search][:date_gteq]).in_time_zone(current_user.time_zone).strftime("%Y-%m-%d")
    e_date = Chronic.parse(params[:search][:date_lteq]).in_time_zone(current_user.time_zone).strftime("%Y-%m-%d")
    @no_of_day = ((e_date.to_date-s_date.to_date).to_i)+1
    search[:starts_at_gteq] = "#{s_date} 00:00:00"
    search[:starts_at_lteq] = "#{e_date} 23:59:59"
    @meetings = ConversationItemSearch.all(params: { user_ids: user_ids, search: search })
    if @meetings.next_page
      if @meetings.total_entries > 500
        flash[:danger] = 'Sorry, we are unable to process your request. The max result limit has been reached.
Please contact your administrator to help generate a report.'
        redirect_to meeting_report_path
      else
        total_page = (@meetings.total_entries.to_f/50).ceil
        @meetings = []
        (1..total_page).each do |n|
          @meetings << ConversationItemSearch.all(params: { user_ids: user_ids, search: search, page: n, per_page: 50 })
          @meetings = @meetings.flatten
        end
      end
    end
    day_of_Week_bar_chart_data(@meetings)
    # time_of_day_bar_chart_data(@meetings)
    meetings_by_account_status_data(@meetings)
    meeting_by_status_chart_data(@meetings)
    type_of_meetings_bar_chart(@meetings)

    @total_meetings = @meetings.count
    @meetings_per_day = (@total_meetings.to_f/@no_of_day.to_f).round(1)
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
        @total_check_in += meeting.check_ins.count
        @total_check_out += meeting.check_outs.count
        starts_at = Chronic.parse(meeting.starts_at).in_time_zone(current_user.time_zone).to_s
        ends_at = Chronic.parse(meeting.ends_at).in_time_zone(current_user.time_zone).to_s
        @meeting_time_in_second += (Time.parse(ends_at) - Time.parse(starts_at))
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

  def activity_report_result
    search = Hash[]
    if current_user.roles.last.try(:name) == 'User'
      user_ids = [current_user.id]
    else
      if params[:users].present?
        if params[:users].include? 'all'
          user_ids = User.all(uid: session[:user_id], reload: true).map(&:id)
        else
          user_ids = params[:users]
        end
      else
        user_ids = [current_user.id]
      end
    end
    s_date = Chronic.parse(params[:search][:date_gteq]).in_time_zone(current_user.time_zone).strftime('%Y-%m-%d')
    e_date = Chronic.parse(params[:search][:date_lteq]).in_time_zone(current_user.time_zone).strftime('%Y-%m-%d')

    search[:updated_at_gteq] = "#{s_date} 00:00:00"
    search[:updated_at_lteq] = "#{e_date} 23:59:59"
    search[:user_id_in] = user_ids

    # get a list of all accounts updated between selected date range
    no_of_account = Account.all.total_entries
    @accounts = Account.all(params: { search: search, per_page: no_of_account})
    @accounts = @accounts.sort_by { |account| account.updated_at }.reverse
    # remove this key from search since we use the same search hash below
    search.delete(:user_id_in)

    # we can use the same params since items table also used "updated_at"
    @citems = ConversationItemSearch.all(params: { user_ids: user_ids, search: search })
    if @citems.next_page
      if @citems.total_entries > 500
        flash[:danger] = 'Sorry, we are unable to process your request. The max result limit has been reached.
Please contact your administrator to help generate a report.'
        redirect_to activity_report_path
      else
        total_page = (@citems.total_entries.to_f/50).ceil
        @citems = []
        (1..total_page).each do |n|
          @citems << ConversationItemSearch.all(params: { user_ids: user_ids, search: search, page: n, per_page: 50 })
          @citems = @citems.flatten
        end
      end
    end

    # find the counts for each type of event that has happened
    @totals = { general_meeting: 0, regular_meeting: 0 }

    @sorted_citems = Hash[]
    @sorted_citems[:meeting] = Array[]
    @sorted_citems[:quote] = Array[]
    @sorted_citems[:reminder] = Array[]
    @sorted_citems[:note] = Array[]
    @sorted_citems[:email] = Array[]
    @sorted_citems[:account] = Array[]
    @citems.each do |citem|
      if (citem.type == 'meeting')
        if (citem.item_type == 'regular')
          @totals[:regular_meeting] += 1
        else
          @totals[:general_meeting] += 1
        end
      end
      @sorted_citems[citem.type.to_sym].push(citem)
    end
  end

  def sales_report_result
    if current_user.roles.last.try(:name) == 'User'
      user_ids = [current_user.id]
    else
      if params[:users].present?
        if params[:users].include? 'all'
          user_ids = User.all(uid: session[:user_id], reload: true).map(&:id)
        else
          user_ids = params[:users]
        end
      else
        user_ids = [current_user.id]
      end
    end

  end

  private

  def meeting_by_status_chart_data(meetings)
    s = 0
    c = 0
    can = 0
    if meetings.present?
      meetings.each do |m|
        if m.status == 'scheduled'
          s = s + 1
        elsif m.status == 'completed'
          c = c + 1
        elsif m.status == 'canceled'
          can = can + 1
        end
      end
    end
    scheduled = ((s.to_f/meetings.size.to_f)*100).round(2) rescue 0
    completed = ((c.to_f/meetings.size.to_f)*100).round(2) rescue 0
    cancelled = ((can.to_f/meetings.size.to_f)*100).round(2) rescue 0
    @meeting_by_status = [{label: 'Scheduled', value: scheduled},
                         {label: 'Completed', value: completed},
                         {label: 'Canceled', value: cancelled}]
    @meeting_by_status = @meeting_by_status.to_json
  end

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
      v = ((v.to_f/meetings.size.to_f)*100).round(2) rescue 0
      arr << {label: k.to_s, value: v}
    end
    @account_data = arr.to_json
  end

  def type_of_meetings_bar_chart(meetings)
    date_range = Chronic.parse(params[:search][:date_gteq]).in_time_zone(current_user.time_zone).strftime("%b %d %Y") + " to " + Chronic.parse(params[:search][:date_lteq]).in_time_zone(current_user.time_zone).strftime("%b %d %Y")
    g_meeting = 0
    r_meeting = 0
    if meetings.present?
      meetings.each do |meeting|
        if meeting.item_type == 'regular'
          r_meeting += 1
        else
          g_meeting += 1
        end
      end
    end
    @meeting_comparison_data = [{ y: date_range, a: g_meeting, b: r_meeting }]
    @meeting_comparison_data = @meeting_comparison_data.to_json
  end
end
