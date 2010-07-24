class RRDGoogleChart

    def initialize
        @plot_data = {}
        @columns = []
        @row_count = 0
        @data_points = []
    end
    
    def add_plot_data(title, plot_data)
        @plot_data[title] = plot_data
    end
    
    def graph
        series_count = 0
        @plot_data.each do |title, plot_data|
            series_count += 1
            @columns << "data.addColumn('number', '#{title}');"
            @columns << "data.addColumn('string', 'title#{series_count}');"
            @columns << "data.addColumn('string', 'text#{series_count}');"
            plot_data.each_index do |i|
		@row_count += 1
                data_point = plot_data[i]
                time_value = Time.at(data_point.first.to_i)
                data_value = data_point.last
                @data_points << "data.setValue(#{i}, 0, new Date(#{time_value.year}, #{time_value.month.to_i() - 1} ,#{time_value.day}, #{time_value.hour}, #{time_value.min}, #{time_value.sec}));"
                @data_points << "data.setValue(#{i}, #{(series_count==1)? 1 : 1 + (series_count-1)*3}, #{data_value});"
            end
        end
    end
    
    def to_js
        javascript = %[
        function drawVisualization() {
          var data = new google.visualization.DataTable();
          data.addColumn('date', 'Date');
          %s
          
          var annotatedtimeline = new google.visualization.AnnotatedTimeLine(
              document.getElementById('visualization'));
          annotatedtimeline.draw(data, {'displayAnnotations': true, 'dateFormat' : 'HH:mm MMMM dd, yyyy'});
        }]
        
        columns = @columns.join("\n")
	rows = "data.addRows(#{@row_count});\n"
        data_points = @data_points.join("\n")
        
        javascript % (columns + rows + data_points)
    end
end

if __FILE__ == $0
    if ARGV[0]
        require 'rrd_fetch.rb'
        data = rrd_fetch(ARGV[0])
        data.delete_at(0)
        data = data.select{|d| not d[1].nan? }
        chart = RRDGoogleChart.new
        chart.add_plot_data('CPU', data)
        chart.graph
        puts chart.to_js
    end
end
