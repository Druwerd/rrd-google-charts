#!/usr/bin/ruby

require 'google_chart.rb'

class AnnotatedTimeline < GoogleChart

  def initialize(element_id='visualization', width=800, height=400)
    super(self.class.to_s.downcase, element_id)
    @plot_data = {}
  end

  def add_data(title, plot_data)
    @re_graph = true
    @plot_data[title] = plot_data
  end

  private
  def graph
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
    chart = AnnotatedTimeline.new
    ARGV.each do |file|
      title = File.basename(file, '.rrd')
      data = rrd_fetch(file)
      data.delete_at(0)
      data = data.select{|d| not d[1].nan? }
      chart.add_data(title, data)
    end
    puts chart.to_html
  end
end
