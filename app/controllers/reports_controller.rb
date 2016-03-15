class ReportsController < ApplicationController
  def meeting_report
  end

  def meeting_report_result
    @meetings = ConversationItemSearch
  end
end
