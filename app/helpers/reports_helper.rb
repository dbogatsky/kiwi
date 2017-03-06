module ReportsHelper
  COLOUR_PALETTES = ["#1CAF9A", "#428BCA", "#7A92A3", "#0B62A4", "#5BC0DE", "#D9534F", "#F0AD4E", "#4CAF50"]

  def chart_morris_bar(chart_data)
    chart_html = ''
    chart_html += chart_layout(chart_data[:title], chart_data[:id_name])
    chart_html.html_safe
  end

  def chart_morris_donut(chart_data)
    chart_html = ''
    chart_html += chart_layout(chart_data[:title], chart_data[:id_name])
    chart_html.html_safe
  end

  def chart_flot_bar(chart_data)
    chart_html = ''
    chart_html += chart_layout(chart_data[:title], chart_data[:id_name])
    chart_html.html_safe
  end

  def chart_flot_pie(chart_data)
    chart_html = ''
    chart_html += chart_layout(chart_data[:title], chart_data[:id_name])
    chart_html.html_safe
  end


  def chart_layout(chart_title, chart_div_id, layout_col_size='col-sm-6')
    chart_layout_html = ''

    chart_layout_html += "
    <div class=\"#{layout_col_size}\">
      <div class=\"panel panel-report panel-alt\">
    "

    if chart_title.present?
      chart_layout_html += "  
        <div class=\"panel-heading\">
          <h3 class=\"panel-title\">#{chart_title}</h3>
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

#    piedata = [
#        { label: 'Series 1', data: [[1,10]], color: '#D9534F'},
#        { label: 'Series 2', data: [[1,30]], color: '#1CAF9A'},
#        { label: 'Series 3', data: [[1,90]], color: '#F0AD4E'},
#        { label: 'Series 4', data: [[1,70]], color: '#428BCA'},
#        { label: 'Series 5', data: [[1,80]], color: '#5BC0DE'}
#    ];

    chart_js += "

    var piedata = [
        { label: 'Series 1', data: [[1,10]], color: '#D9534F'},
        { label: 'Series 2', data: [[1,30]], color: '#1CAF9A'},
        { label: 'Series 3', data: [[1,90]], color: '#F0AD4E'},
        { label: 'Series 4', data: [[1,70]], color: '#428BCA'},
        { label: 'Series 5', data: [[1,80]], color: '#5BC0DE'}
      ];

    jQuery.plot('##{chart_data[:id_name]}', piedata, {
        series: {
            pie: {
                show: true,
                radius: 1,
                label: {
                    show: true,
                    radius: 2/3,
                    formatter: labelFormatter,
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

    chart_js.html_safe
  end

  def chart_morris_donut_js(chart_data)
    chart_js = ''

    chart_js += "
    var #{chart_data[:id_name]}_data =  [ 
        { label: 'Tier A', value: 60.00 },
        { label: 'Tier B', value: 30.00 },
        { label: 'Tier C', value: 10.00 }
      ];

    var #{chart_data[:id_name]} =  new Morris.Donut({
      element: '#{chart_data[:id_name]}',
      data: #{chart_data[:id_name]}_data,
      resize: true,
      stacked: true,
      colors: ['#428BCA', '#4CAF50', '#999'],
      formatter: function (y, data) { return y + '%'}
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
      stacked: true,
      resize: true,
      hideHover: true
    });
    "

    chart_js.html_safe
  end

  def table_data_detail(data)
    table_html = ''

    table_html += "
    <div class=\"col-sm-12\">
      <div class=\"panel panel-report panel-alt\">
        <div class=\"panel-heading\">
          <h3 class=\"panel-title\">Sales by Tier Data Table</h3>
        </div>
        <div class=\"panel-body\">
          <div class=\"table-responsive\">"

    table_html += table_data_layout(table_headings, table_data)

    table_html += "
          </div>
        </div><!-- panel-body -->
      </div>
    </div>
    "

    table_html.html_safe
  end


  def table_data_trending(data)
    table_html = ''

    table_html += "
    <div class=\"col-md-6\">
      <div class=\"panel panel-alt\">
        <div class=\"panel-heading\">
          <h5 class=\"panel-title\">Bottom Trending Products</h5>
        </div>
        <div class=\"panel-body panel-table\">
          <div class=\"table-responsive\">"

    table_html += table_data_layout(table_headings, table_data, show_percentage_bar, percentage_index)

    table_html += "
          </div><!-- table-responsive -->
        </div><!-- panel-body -->
      </div><!-- panel -->
    </div><!-- col-md-6 -->
    "

    table_html.html_safe
  end

  def table_data_layout(table_headings, table_data, show_percentage_bar=false, percentage_index='')
    table_data_html = ''

    table_data_html += "
      <table class=\"table\">"
    
    if table_headings.count > 0
      table_data_html += "
        <thead>
          <tr class=\"table-head-alt\">"

      table_headings.each do |table_heading|
        table_data_html += "
            <th>#{table_heading}</th>"
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

      table_data.each do |data_item|
        table_data_html += "
            <td>#{data_item}</td>"
      end
      if show_percentage_bar
        table_data_html += "
            <td></td>
            <td></td>"
      end
      table_data_html += "
          </tr>"      
    end
    table_data_html += "
        </tbody>"
    

    table_data_html += "</table>"

    table_data_html
  end

  def table_data_percentage_bar(percentage)

  end

  # panel_icon can be any font awesome icon
  # panel_style can be any one in [success, primary, info, warning, danger, dark]
  def panel_quick_stat(quick_stat_data, panel_icon='fa-exclamation', panel_style='success')
    quick_stat_html = ''

    quick_stat_data = { main_stat: { label: 'Grand Total Of Sales (000\'s)', value: '$10,000'},
                        sub1_stat: { label: 'AVG Per Week', value: '$1500'},
                        sub2_stat: { label: 'AVG Per Day', value: '$200'}
                      }

    quick_stat_html += "
      <div class=\"col-sm-6 col-md-3\">
        <div class=\"panel panel-#{panel_style} panel-stat\">
          <div class=\"panel-heading\">
            <div class=\"stat\">
              <div class=\"row\">
                <div class=\"col-xs-4\">
                  <i class=\"fa #{panel_icon}\"></i>
                </div>
                <div class=\"col-xs-8 text-center\">
                  <small class=\"stat-label\"><strong>#{quick_stat_data[:main_stat][:label]}</strong></small>
                  <h1>#{quick_stat_data[:main_stat][:value]}</h1>
                </div>
              </div><!-- row -->
              <div class=\"mb15\"></div>
              <div class=\"row\">
                <div class=\"col-xs-6 text-center\" style=\"padding-left: 0px\">
                  <small class=\"stat-label\"><strong>#{quick_stat_data[:sub1_stat][:label]}</strong></small>
                  <h4>#{quick_stat_data[:sub1_stat][:value]}</h4>
                </div>
                <div class=\"col-xs-6 text-center\" style=\"padding-right: 0px\">
                  <small class=\"stat-label\"><strong>#{quick_stat_data[:sub2_stat][:label]}</strong></small>
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

    ranking_stat_data = [ 'Product 1', 
                          'Product 2',
                          'Product 3',
                          'Product 4',
                          'Product 5',
                        ]

    ranking_stat_html += "
      <div class=\"col-sm-6 col-md-3\">
        <div class=\"panel panel-#{panel_style} panel-stat\"  style=\"height: 145px;\">
          <div class=\"panel-heading\">
            <div class=\"stat\">
              <div class=\"row\">
                <div class=\"col-xs-4\">
                 <i class=\"fa #{panel_icon}\"></i>
                </div>
                <div class=\"col-xs-8 text-center\">
                  <small class=\"stat-label\"><strong>Top Performing Products</strong></small>
                  <small class=\"stat-label\" style=\"text-align: left; padding-left: 10px;\">
                  <h6>"

    ranking_stat_data.each do |data_item|
      ranking_stat_html += "
      #{data_item}<br />"
    end

    ranking_stat_html += "
                  </h6>
                  </small>
                </div>
              </div>
              <div class=\"mb15\"></div>
            </div><!-- stat -->
          </div><!-- panel-heading -->
        </div><!-- panel -->
      </div><!-- col-sm-6 -->
    "

    ranking_stat_html.html_safe
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
