def get_extents file_name
	`filefrag "#{file_name}"`.scan(/\d+/).last.to_i
end

files = []
Dir.glob("**/*") do |file_name|
	next if File.directory? file_name
	
	files << {:name => file_name, 
			:extents => get_extents(file_name),
			:size => File.size(file_name)
			}
end

puts "extents\tsize\tfile"
files.sort {|a1,a2| a2[:extents] <=> a1[:extents]}.each do |f|
	puts f[:extents].to_s + "\t" + f[:size].to_s + "\t" + f[:name]
end


