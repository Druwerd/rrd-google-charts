require 'rubygems'
require 'rrd'

class GoogleChart

  attr_accessor :chart_type, :options, :data, :width, :height, :rrd_files
  attr_reader :javascript, :html

  def initialize(chart_type, element_id='visualization', width=800, height=400)
    @chart_type = chart_type
    @javascript = ""
    @html = ""
    @options = []
    @element_id = element_id
    @data = ""
    @width = width
    @height = height
    @re_graph = false
    @rrd_files = []
  end

  def << file
    if File.exists?(file)
        @rrd_files << file
        @re_graph = true
    else
        raise "File #{file} does not exist"
    end
  end
  
  private
  def graph
    fetch_data()
    # overide this function to populate @data
  end
  
  def add_data(title, plot_data)
    @re_graph = true
    @plot_data[title] = plot_data
  end
  
  def fetch_data()
    @rrd_files.each do |file|
        title = File.basename(file, '.rrd')
        title = "#{$1}-#{title}" if file =~ /collectd\/(.+)\.gnmedia\.net/
        data = rrd_fetch(file)
        add_data(title, data)
    end
  end
  
  def rrd_fetch(filename, consolidation_function="AVERAGE", start_time=nil, end_time=nil)
    start_time ||= Time.now - 60 * 60 * 24 * 30
    end_time ||= Time.now

    data = RRD::Wrapper.fetch(filename, "--start", start_time.to_i.to_s, "--end", end_time.to_i.to_s, consolidation_function)
    data.delete_at(0)
    data = data.select{|d| not d[1].nan?}
    data
  end

  public
  def to_js
    graph if @re_graph
    javascript = <<-EOS
      google.load('visualization', '1', {packages: ['#{@chart_type}']});
      function drawVisualization() {
        var data = new google.visualization.DataTable();
        %s
        var annotatedtimeline = new google.visualization.#{self.class}(document.getElementById('#{@element_id}'));
        annotatedtimeline.draw(data, {#{@options.join(', ')}});
      }
      google.setOnLoadCallback(drawVisualization);
    EOS
    @javascript = javascript % @data
  end

  def to_html
    html = %{
    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
    <html xmlns="http://www.w3.org/1999/xhtml">
    <head>
      <meta http-equiv="content-type" content="text/html; charset=utf-8" />
      <title>Google Visualization API Sample</title>
      <script type="text/javascript" src="http://www.google.com/jsapi"></script>
      <script type="text/javascript">
      %s
      </script>
    </head>
    <body style="font-family: Arial;border: 0 none;">
    <div id="#{@element_id}" style="width: #{@width}px; height: #{@height}px;"></div>
    </body>
    </html>}

    html % self.to_js
  end
  
end
