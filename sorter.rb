require 'exifr'
require 'fileutils'

if ARGV.length != 2 
	puts "Usage: ruby sorter.rb destination_dir search_dir"
	Process.exit
end

$destination_dir = ARGV[0]
puts "Destination Dir is #{$destination_dir}"

search_dir = ARGV[1]
puts "Searching dir  #{search_dir}"

$default_dir = $destination_dir +"/default"
Dir.mkdir($default_dir)

#See if the file is a JPEG file. If it is then put the file into a folder whose name is equal the month/year the picture was taken
#If there is no date on the picture , put it into a default folder
def sort_file(filename)
	begin
		file  = File.new(filename)
		if filename.downcase.end_with?("jpeg") || filename.downcase.end_with?("jpg")
			time = EXIFR::JPEG.new(filename).date_time
			if(time.nil?)
				puts "Putting file #{filename} in #{$default_dir+"/"+File.basename(filename)}"
				FileUtils.cp(filename,$default_dir+"/"+File.basename(filename))
				return;
			end
			dir_name = time.month.to_s+"-"+time.year.to_s
			if !File.exists?($destination_dir+"/"+dir_name)
				puts "Creating dir #{$destination_dir+"/"+dir_name}"
				Dir.mkdir($destination_dir+"/"+dir_name)
			end
			#puts "Putting file #{filename} in #{$destination_dir+"/"+dir_name}"
			FileUtils.cp(filename,$destination_dir+"/"+dir_name)
		end
	rescue
	end
end

#recurse over directories . Call sort() on files.
def recurse(filename)
	file = File.new(filename)
	if File.exists?(filename)
		if File.directory?(filename)
			Dir.entries(filename).each do |x|
				full_name = File.absolute_path(filename)+"/"+x
				if  x !="." && x != ".." && File.directory?(full_name)
					recurse (full_name)
				else
					sort_file (full_name)
				end
				
			end
		end
	end
end

def extract_info (filename)
	recurse(filename)
end


extract_info(search_dir)


