#!/usr/bin/ruby 

require 'rubygems'
require 'rrd'

def rrd_fetch(filename, consolidation_function="AVERAGE", start_time=nil, end_time=nil)
    start_time ||= Time.now - 60 * 60 * 24 * 30
    end_time ||= Time.now

    RRD::Wrapper.fetch(filename, "--start", start_time.to_i.to_s, "--end", end_time.to_i.to_s, consolidation_function)
end

def main(args)
    filename = args[0]
    consolidation_function = args[1] || "AVERAGE"
    start_time = args[2]
    end_time = args[3]

    rrd_fetch(filename, consolidation_function, start_time, end_time)
end

if __FILE__ == $0
    if ARGV[0]
        puts main(ARGV)
    end
end
