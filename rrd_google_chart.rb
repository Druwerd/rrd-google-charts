class RRDGoogleChart

    def initialize
        @plot_data = {}
        @columns = []
        @column_count = 0
        @data_points = []
    end
    
    def add_plot_data(title, plot_data)
        @plot_data[title] = plot_data
    end
    
    def graph
        @column_count = @plot_data.keys.size
        series_count = 0
        @plot_data.each do |title, plot_data|
            series_count += 1
            @columns += "data.addColumn('number', '#{title}');"
            @columns += "data.addColumn('string', 'title#{series_count}');"
            @columns += "data.addColumn('string', 'text#{series_count}');"
            plot_data.each_index do |i|
                data_point = plot_data[i]
                time_value = Time.new(data_point.first.to_i)
                data_value = data_point.last
                @data_points += "data.setValue(#{i}, 0, new Date(#{time_value.year}, #{time_value.month.to_i -1} ,#{time_value.day}));"
                @data_points += "data.setValue(#{i}, #{(series_count==1)? 1 : 1 + (series_count-1)*3}, #{data_value});"
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
          annotatedtimeline.draw(data, {'displayAnnotations': true});
        }]
        
        columns = @coluns.join("\n")
        data_points = @data_points.join("\n")
        
        javascript % columns + data_points
    end
end