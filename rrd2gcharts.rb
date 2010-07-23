#!/usr/bin/ruby

require 'rrd_fetch.rb'

$chart_url= %{http://chart.apis.google.com/chart
?chxl=0:|0%3A00|4%3A00|8%3A00|12%3A00|16%3A00|20%3A00|24%3A00
&chxp=0,0,16,32,48,64,80,96
&chxs=0,676767,11.5,-1,l,676767
&chxt=x,y
&chs=600x300
&cht=lxy
&chco=3072F3,FF0000
&chd=t:%s
&chdl=Data1
&chdlp=b
&chg=16,10
&chls=2,4,1|1
&chma=5,5,5,25
&chtt=Title}

$chart_url = $chart_url.gsub("\n",'')

def get_data_points(filename, minutes_ago=120)
    start_time = Time.now - 60 * minutes_ago.to_i
    data = rrd_fetch(filename, "AVERAGE", start_time)
    data_points = data.collect{|p| (p[1].to_s=~/\d/)? p[1].to_i.to_s : '0'}
    data_points.delete_at(0)
    data_param = "-1|" + data_points.join(",")
    data_param
end

def chart(path)
    rrd_files = []
    data_points = ""
    if File.directory?(path)
        rrd_files = Dir.entries(path).select{|e| File.extname(e) == '.rrd'} 
        rrd_files = rrd_files.collect{|f| File.join(path, f)}
    elsif File.exists?(path)
    puts "Invalid file: #{path}" if File.extname(path) != '.rrd'
    rrd_files = path
    end
    puts rrd_files
    rrd_files.each do |rrd_file|
       data_points += get_data_points(rrd_file)
    end
    puts $chart_url % data_points
end

if __FILE__ == $0
    if ARGV[0]
        chart(ARGV[0])
    end 
end
