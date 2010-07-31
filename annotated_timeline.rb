#!/usr/bin/ruby

require 'google_chart.rb'

class AnnotatedTimeLine < GoogleChart

  def initialize(element_id='visualization', width=800, height=400)
    super(self.class.to_s.downcase, element_id)
    @plot_data = {}
    @options << "'displayAnnotations': true"
    @options << "'dateFormat' : 'HH:mm MMMM dd, yyyy'"
    @options << "'legendPosition': 'newRow'"
    
    zoom_start_time = Time.now - 60*60*24
    zoom_end_time = Time.now
    @options << "'zoomStartTime': new Date(#{zoom_start_time.year}, #{zoom_start_time.month.to_i() - 1}, #{zoom_start_time.day}, #{zoom_start_time.hour}, #{zoom_start_time.min})"
    @options << "'zoomEndTime': new Date(#{zoom_end_time.year}, #{zoom_end_time.month.to_i() - 1}, #{zoom_end_time.day}, #{zoom_end_time.hour}, #{zoom_end_time.min})"
  end

  private
  def graph
    super()
    @data = ""
    columns = ["data.addColumn('date', 'Date');"]
    row_count = 0
    data_points = []
    series_count = 0
    @plot_data.each do |title, plot_data|
      series_count += 1
      columns << "data.addColumn('number', '#{title}');"
      columns << "data.addColumn('string', 'title#{series_count}');"
      columns << "data.addColumn('string', 'text#{series_count}');"
      plot_data.each_index do |i|
        row_count += 1
        data_point = plot_data[i]
        time_value = Time.at(data_point.first.to_i)
        data_value = data_point.last
        data_points << "data.setValue(#{i}, 0, new Date(#{time_value.year}, #{time_value.month.to_i() - 1} ,#{time_value.day}, #{time_value.hour}, #{time_value.min}, #{time_value.sec}));"
        data_points << "data.setValue(#{i}, #{(series_count==1)? 1 : 1 + (series_count-1)*3}, #{data_value});"
      end
    end

    columns = columns.join("\n")
    rows = "data.addRows(#{row_count});\n"
    data_points = data_points.join("\n")

    @data = columns + rows + data_points
  end
  
end

if __FILE__ == $0
  if ARGV[0]
    require 'rrd_fetch.rb'
    chart = AnnotatedTimeLine.new
    ARGV.each do |file|
      chart << file
    end
    puts chart.to_html
  end
end
