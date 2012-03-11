#!/usr/bin/env ruby

require "getoptlong"

def get_extents file_name
	`filefrag "#{file_name}"`.scan(/\d+/).last.to_i
end

def human2bytes human_read_size
	eval human_read_size.gsub(/[KMG]/, "K" => "*1024", "M" => "*1048576", "G" => "*1073741824")
end

opts = GetoptLong.new(
	[ "--help", "-h", GetoptLong::NO_ARGUMENT ],
	[ "--size", "-s", GetoptLong::REQUIRED_ARGUMENT ],
	[ "--extents", "-e", GetoptLong::REQUIRED_ARGUMENT ]
)

filter_size = 0
filter_extents = 0

opts.each do |opt, arg|
	case opt
		when "--size"
		filter_size = human2bytes arg
		when "--extents"
		filter_extents = arg.to_i
		when '--help'
		puts <<-EOF
-h, --help:
   show help

-s, --size x:
   skip files that are smaller then x bytes. Can be in human readable format (e.g. 10M, 2G)

-e, --extents x:
   skip files that have less then x extents
EOF
		exit
	end
end

files = []
Dir.glob("**/*") do |file_name|
	next if File.directory? file_name
	
	next if (file_size = File.size(file_name)) < filter_size
	next if (file_extents = get_extents(file_name)) < filter_extents
	
	files << {:name => file_name, :extents => file_extents,	:size => file_size}
end

puts "extents\tsize\tfile"
files.sort {|a1,a2| a2[:extents] <=> a1[:extents]}.each do |f|
	puts f[:extents].to_s + "\t" + f[:size].to_s + "\t" + f[:name]
end