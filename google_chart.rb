class GoogleChart

  attr_accessor :chart_type, :options, :data, :width, :height
  attr_reader :javascript, :html

  def initialize(chart_type, element_id='visualization', width=800, height=400)
    @chart_type = chart_type
    @javascript = ""
    @html = ""
    @options = ""
    @element_id = element_id
    @data = ""
    @width = width
    @height = height
    @re_graph = false
  end

  private
  def graph
    # overide this function to populate @data
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
        annotatedtimeline.draw(data, {#{@options}});
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
