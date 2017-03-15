module ReportsHelper
  COLOUR_PALETTES = ["#1CAF9A", "#428BCA", "#7A92A3", "#0B62A4", "#5BC0DE", "#D9534F", "#F0AD4E", "#4CAF50"]

  def chart_morris_bar(chart_data, layout_col_size='col-sm-6')
    chart_html = ''
    chart_html += chart_layout(chart_data[:title], chart_data[:id_name], layout_col_size)
    chart_html.html_safe
  end

  def chart_morris_donut(chart_data, layout_col_size='col-sm-6')
    chart_html = ''
    chart_html += chart_layout(chart_data[:title], chart_data[:id_name], layout_col_size)
    chart_html.html_safe
  end

  def chart_flot_bar(chart_data, layout_col_size='col-sm-6')
    chart_html = ''
    chart_html += chart_layout(chart_data[:title], chart_data[:id_name], layout_col_size)
    chart_html.html_safe
  end

  def chart_flot_pie(chart_data, layout_col_size='col-sm-6')
    chart_html = ''
    chart_html += chart_layout(chart_data[:title], chart_data[:id_name], layout_col_size)
    chart_html.html_safe
  end

  def chart_layout(chart_title, chart_div_id, layout_col_size)
    chart_layout_html = ''

    chart_layout_html += "
    <div class=\"#{layout_col_size}\">
      <div class=\"panel panel-report panel-alt\">
    "

    if chart_title.present?
      chart_layout_html += "  
        <div class=\"panel-heading\">
          <h3 class=\"panel-title-reporting\">#{chart_title}</h3>
        </div>
    "    
    end

    chart_layout_html += "
        <div class=\"panel-body\">
         <div id=\"#{chart_div_id}\" class=\"chart-height\"></div>
        </div><!-- panel-body -->
      </div>
    </div>
    "

    chart_layout_html
  end


  def chart_flot_pie_js(chart_data)
    chart_js = ''

    chart_js += "
    var #{chart_data[:id_name]}_data = #{chart_data[:data].to_json};

    jQuery.plot('##{chart_data[:id_name]}', #{chart_data[:id_name]}_data, {
      series: {
        pie: {
          show: true,
          radius: 1,
          label: {
            show: true,
            radius: 2/3,
            formatter: #{chart_data[:id_name]}_labelFormatter,
            threshold: 0.1
          }
        }
      },
      grid: {
        hoverable: true,
        clickable: true
      }
    });
    "

    chart_js += "
    function #{chart_data[:id_name]}_labelFormatter(label, series) {
    return \"<div style='font-size:8pt; text-align:center; padding:2px; color:white;'>\" + label + \"<br/>\" + Math.round(series.percent) + \"%</div>\";
    }
    "

    chart_js.html_safe
  end

  def chart_flot_singlebar_js(chart_data)
    chart_js = ''

    unless chart_data[:fillColor].present?
      chart_data[:fillColor] = default_colour_palettes(1).first
    end

    chart_js += "
    var #{chart_data[:id_name]}_data = #{chart_data[:data].to_json};

    jQuery.plot(\"##{chart_data[:id_name]}\", [ #{chart_data[:id_name]}_data ], {
      series: {
        lines: {
          lineWidth: 1  
        },
        bars: {
          show: true,
          barWidth: 0.5,
          align: 'center',
          lineWidth: 0,
          fillColor: \"#{chart_data[:fillColor].to_s}\"
        }
      },
      grid: {
        borderColor: '#ddd',
        borderWidth: 1,
        labelMargin: 10
      },
      xaxis: {
        mode: 'categories',
        tickLength: 0
      }
    });
    "

    chart_js.html_safe
  end


  def chart_morris_donut_js(chart_data)
    chart_js = ''

    unless chart_data[:colors].present?
      chart_data[:colors] = default_colour_palettes(chart_data[:data].count)
    end

    chart_js += "
    var #{chart_data[:id_name]}_data = #{chart_data[:data].to_json};

    var #{chart_data[:id_name]} =  new Morris.Donut({
      element: '#{chart_data[:id_name]}',
      data: #{chart_data[:id_name]}_data,
      resize: true,
      stacked: true,
      colors: #{chart_data[:colors].to_json},
      formatter: #{chart_data[:formatter]}
    });
    "

    chart_js.html_safe
  end

  def chart_morris_bar_js(chart_data)
    chart_js = ''

    unless chart_data[:barColors].present?
      unless chart_data[:labels].present?
        chart_data[:barColors] = default_colour_palettes(1)
      else
        chart_data[:barColors] = default_colour_palettes(chart_data[:labels].count)
      end
    end

    chart_js += "
    var #{chart_data[:id_name]}_data = #{chart_data[:data].to_json};

    var #{chart_data[:id_name]} = new Morris.Bar({
      element: '#{chart_data[:id_name]}',
      data: #{chart_data[:id_name]}_data,
      xkey: #{chart_data[:xkey].present? ? "'" + chart_data[:xkey] + "'" : "'x'"},
      ykeys: #{chart_data[:ykeys].present? ? chart_data[:ykeys].to_json : "['y']"},
      xLabelMargin: 5,
      labels: #{chart_data[:labels].present? ? chart_data[:labels].to_json : "['Label']"},
      barColors: #{chart_data[:barColors].to_json},
      lineWidth: '1px',
      fillOpacity: 0.8,
      smooth: false,
      hideHover: true,
      #{(chart_data[:stacked].present? && chart_data[:stacked] == 'true') ? "stacked: true," : ""}
      #{(chart_data[:resize].present? && chart_data[:resize] == 'true') ? "resize: true," : ""}
    });
    "

    chart_js.html_safe
  end

  def chart_morris_stacked_bar_js(chart_data)
    chart_js = ''

    unless chart_data[:barColors].present?
      unless chart_data[:labels].present?
        chart_data[:barColors] = default_colour_palettes(1)
      else
        chart_data[:barColors] = default_colour_palettes(chart_data[:labels].count)
      end
    end

    chart_js += "
    var #{chart_data[:id_name]}_data = #{chart_data[:data].to_json};

    var #{chart_data[:id_name]} = new Morris.Bar({
      element: '#{chart_data[:id_name]}',
      data: #{chart_data[:id_name]}_data,
      xkey: #{chart_data[:xkey].present? ? "'" + chart_data[:xkey] + "'" : "'x'"},
      ykeys: #{chart_data[:ykeys].present? ? chart_data[:ykeys].to_json : "['y']"},
      xLabelMargin: 5,
      labels: #{chart_data[:labels].present? ? chart_data[:labels].to_json : "['Label']"},
      barColors: #{chart_data[:barColors].to_json},
      lineWidth: '1px',
      fillOpacity: 0.8,
      smooth: false,
      hideHover: true,
      stacked: true,
    });
    "

    chart_js.html_safe
  end

  def table_data_detail(data)
    table_html = ''

    data[:header] = [] if data[:header].nil?
    data[:data] = [] if data[:data].nil?
    data[:footer] = [] if data[:footer].nil?

    table_html += "
    <div class=\"col-sm-12\">
      <div class=\"panel panel-report panel-alt\">
        <div class=\"panel-heading\">
          <h3 class=\"panel-title-reporting\">#{data[:title]}</h3>
        </div>
        <div class=\"panel-body panel-table\">
          <div class=\"table-responsive\">"

    table_html += table_data_layout(data[:header], data[:data], data[:footer])

    table_html += "
          </div>
        </div><!-- panel-body -->
      </div>
    </div>
    "

    table_html.html_safe
  end

  # panel_style can be any one in [success, primary, info, warning, danger, dark]
  def table_data_trending(data, panel_style='report')
    table_html = ''

    table_html += "
    <div class=\"col-md-6\">
      <div class=\"panel panel-#{panel_style} panel-alt\">
        <div class=\"panel-heading\">
          <h5 class=\"panel-title-reporting\">#{data[:title]}</h5>
        </div>
        <div class=\"panel-body panel-table\">
          <div class=\"table-responsive\">"

    table_html += table_data_layout(data[:header], data[:data])

    table_html += "
          </div><!-- table-responsive -->
        </div><!-- panel-body -->
      </div><!-- panel -->
    </div><!-- col-md-6 -->
    "

    table_html.html_safe
  end

  # panel_style can be any one in [success, primary, info, warning, danger, dark]
  def table_data_trending_percentage_bar(data, panel_style='report')
    table_html = ''

    table_html += "
    <div class=\"col-md-6\">
      <div class=\"panel panel-#{panel_style} panel-alt\">
        <div class=\"panel-heading\">
          <h5 class=\"panel-title-reporting\">#{data[:title]}</h5>
        </div>
        <div class=\"panel-body panel-table\">
          <div class=\"table-responsive\">"

    table_html += table_data_layout(data[:header], data[:data], [], true)

    table_html += "
          </div><!-- table-responsive -->
        </div><!-- panel-body -->
      </div><!-- panel -->
    </div><!-- col-md-6 -->
    "

    table_html.html_safe
  end

  def table_data_layout(table_headings, table_data, table_footers=[], show_percentage_bar=false)
    # Note: if show_percentage_bar is true, then make sure that the percentage column is the last item of the array
    table_data_html = ''

    last_column_index = table_headings.count - 1
    last_item = ''

    table_data_html += "
      <table class=\"table table-hover table-reporting\">"
    
    if table_headings.count > 0
      table_data_html += "
        <thead>
          <tr class=\"table-head-alt\">"

      percentage_counter = 0
      table_headings.each do |table_heading|
        table_data_html += "
            <th>#{table_heading}</th>" unless show_percentage_bar && percentage_counter == last_column_index
        percentage_counter += 1
      end

      if show_percentage_bar
        table_data_html += "
            <th>Percentage</th>
            <th></th>"
      end

      table_data_html += "
          </tr>
        </thead>"
    end

    table_data_html += "
        <tbody>"

    table_data.each do |table_data|
      table_data_html += "
          <tr>"

      percentage_counter = 0
      table_data.each do |data_item|
        table_data_html += "
            <td>#{data_item}</td>" unless show_percentage_bar && percentage_counter == last_column_index
        last_item = data_item if show_percentage_bar && percentage_counter == last_column_index
        percentage_counter += 1
      end
      if show_percentage_bar
        percentage_bar = table_data_percentage_bar(last_item)
        table_data_html += "
            <td>#{percentage_bar}</td>
            <td>#{last_item}</td>"
      end
      table_data_html += "
          </tr>"      
    end
    table_data_html += "
        </tbody>"
    
    table_data_html += "
        <tfoot>
          <tr class=\"table-head-alt\">"

      table_footers.each do |table_footer|
        table_data_html += "
            <td>#{table_footer}</td>"
      end
    table_data_html += "
          </tr>
        </tfoot>"

    table_data_html += "</table>"

    table_data_html
  end

  def table_data_percentage_bar(percentage)
    percentage_bar_html = ''

    percentage_number = percentage.delete("^0-9")
    percentage_width = percentage_number.to_i > 2 ? percentage_number : "3"

    percentage_bar_html += "
                              <div class=\"progress\">
                                  <div style=\"width: #{percentage_width}%\" aria-valuemax=\"100\" aria-valuemin=\"0\" aria-valuenow=\"#{percentage_width}\" role=\"progressbar\" class=\"progress-bar progress-bar-primary\">
                                    <span class=\"sr-only\">#{percentage_number}%</span>
                                  </div>
                              </div>"

    percentage_bar_html
  end

  # panel_icon can be any font awesome icon
  # panel_style can be any one in [success, primary, info, warning, danger, dark]
  def panel_quick_stat(quick_stat_data, panel_icon='fa-exclamation', panel_style='success')
    quick_stat_html = ''

    if quick_stat_data[:main_stat].nil?
      quick_stat_data[:main_stat] = { label: '&nbsp;', value: '&nbsp;'}
    else
      quick_stat_data[:main_stat][:label] = '&nbsp;' if quick_stat_data[:main_stat][:label].nil?
      quick_stat_data[:main_stat][:value] = '&nbsp;' if quick_stat_data[:main_stat][:value].nil?
    end

    if quick_stat_data[:sub1_stat].nil?
      quick_stat_data[:sub1_stat] = { label: '&nbsp;', value: '&nbsp;'}
    else
      quick_stat_data[:sub1_stat][:label] = '&nbsp;' if quick_stat_data[:main_stat][:label].nil?
      quick_stat_data[:sub1_stat][:value] = '&nbsp;' if quick_stat_data[:main_stat][:value].nil?
    end

    if quick_stat_data[:sub2_stat].nil?
      quick_stat_data[:sub2_stat] = { label: '&nbsp;', value: '&nbsp;'}
    else
      quick_stat_data[:sub2_stat][:label] = '&nbsp;' if quick_stat_data[:main_stat][:label].nil?
      quick_stat_data[:sub2_stat][:value] = '&nbsp;' if quick_stat_data[:main_stat][:value].nil?
    end

    quick_stat_html += "
      <div class=\"col-sm-6 col-md-3\">
        <div class=\"panel panel-#{panel_style} panel-stat\">
          <div class=\"panel-heading\">
            <div class=\"stat\">
              <div class=\"row\">
                <div class=\"col-xs-4\">
                  <i class=\"fa #{panel_icon}\"></i>
                </div>
                <div class=\"col-xs-8 text-center stat-label-quick\">
                  <small class=\"stat-label-quick\"><strong><h5>#{quick_stat_data[:main_stat][:label]}</h5></strong></small>
                  <h1>#{quick_stat_data[:main_stat][:value]}</h1>
                </div>
              </div><!-- row -->
              <div class=\"mb15\"></div>
              <div class=\"row\">
                <div class=\"col-xs-6 text-center stat-label-quick\" style=\"padding-left: 0px\">
                  <small class=\"stat-label-quick\"><strong><h5>#{quick_stat_data[:sub1_stat][:label]}</h5></strong></small>
                  <h4>#{quick_stat_data[:sub1_stat][:value]}</h4>
                </div>
                <div class=\"col-xs-6 text-center stat-label-quick\" style=\"padding-right: 0px\">
                  <small class=\"stat-label-quick\"><strong><h5>#{quick_stat_data[:sub2_stat][:label]}</h5></strong></small>
                    <h4>#{quick_stat_data[:sub2_stat][:value]}</h4>
                </div>
              </div>
            </div><!-- stat -->
          </div><!-- panel-heading -->
        </div>
      </div><!-- col-sm-6 -->
    "

    quick_stat_html.html_safe
  end

  # panel_icon can be any font awesome icon
  # panel_style can be any one in [success, primary, info, warning, danger, dark]
  def panel_ranking_stat(quick_stat_data, panel_icon='fa-arrow-up', panel_style='dark')
    ranking_stat_html = ''

    ranking_stat_data = []
    unless quick_stat_data[:data].nil?
      ranking_stat_data = quick_stat_data[:data]
    end

    ranking_stat_html += "
      <div class=\"col-sm-6 col-md-3\">
        <div class=\"panel panel-#{panel_style} panel-stat\">
          <div class=\"panel-heading\">
            <div class=\"stat\">
              <div class=\"row\">
                <div class=\"col-xs-4\">
                 <i class=\"fa #{panel_icon}\"></i>
                </div>
                <div class=\"col-xs-8 text-center\">
                  <small class=\"stat-label-reporting\"><strong><h5>#{quick_stat_data[:title]}</h5></strong></small>
                  <small class=\"stat-label-reporting\" style=\"text-align: left;\">
                  "

    ranking_stat_data.each do |data_item|
      ranking_stat_html += "
                    <h6>#{data_item}</h6>"
    end

    ranking_stat_html += "
                  </small>
                </div>
              </div>
            </div><!-- stat -->
          </div><!-- panel-heading -->
        </div><!-- panel -->
      </div><!-- col-sm-6 -->
    "

    ranking_stat_html.html_safe
  end

  def chart_morris_resize_js(chart_ids)
    chart_js = ''

    chart_js += "
    $(window).resize(function () {"

    chart_ids.each do |chart_id|
      chart_js += "
      #{chart_id}.redraw();"
    end

    chart_js += "
    });
    "

    chart_js.html_safe
  end

  def default_colour_palettes(number_of_bars)
    COLOUR_PALETTES[0, number_of_bars]
  end

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
