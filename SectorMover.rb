require 'find'
require 'fileutils'

#=============================================
#**ETS2 Sector Mover v 1.00 by Narzew
#**v 1.00
#**06.12.15
#**Narzew
#=============================================

module SectorMover

	#=============================================
	#**Create XXXX format from absolute value
	#=============================================

	def self.make_fourdigit(int)
		if int > 0
			sign = "+"
		elsif int < 0
			sign = "-"
		else
			# For 0
			sign = ""
		end
		int = int.abs
		size = int.to_s.size
		if size == 0
			return "#{sign}0000"
		elsif size == 1
			return "#{sign}000#{int}"
		elsif size == 2
			return "#{sign}00#{int}"
		elsif size == 3
			return "#{sign}0#{int}"
		elsif size == 4
			return "#{sign}#{int}"
		end
	end
	
	#=============================================
	#**Swap sectors
	#**filename -> sector default format name
	#**x => x to swap, integer value
	#**y => y to swap, integer value
	#=============================================
	
	def self.swap_sector(filename, x, y)
		#puts filename
		# Sequence format: "sec<+|->XXXX<+|->YYYY.<base|aux|desc> for example:
		# "sec+0017-0012.aux"
		# "sec-0011-0002.desc"
		# "sec-0012+0003.aux"
		# "sec+0017+0011.base"
		# Basic sequence for example: "+XXXX-YYYY"
		base_a = filename.split("sec")[1].split(".")[0]
		# Filename extension
		base_ext = filename.split(".")[1]
		# Sign of sector X
		sign1 = base_a[0]
		# Sign of sector Y
		sign2 = base_a[5]
		# Sector X value (absolute)
		base_x = base_a[1..4].to_i.abs
		# Sector Y value (absolute)
		base_y = base_a[6..9].to_i.abs
		#puts "Sign of X: "#{sign1}"
		#puts "Sign of Y: "#{sign2}"
		
		# Change values appropiate to sign
		if sign1 == "-"
			base_x = -base_x
		end
		if sign2 == "-"
			base_y = -base_y
		end
		
		# Make result string
		result_x = make_fourdigit(base_x+x)
		result_y = make_fourdigit(base_y+y)
		
		result = "sec#{result_x}#{result_y}.#{base_ext}"
		print "#{filename} => #{result}\n"
		return result
	end
	
	#=============================================
	#**Convert all filenames in folder
	#**folder => folder name
	#**swap_x => x swap value
	#**swap_y => y swap value
	#=============================================
	
	def self.swap_all(folder, swap_x, swap_y)
		Find.find(folder){|x|
			filename = x
			x = x.gsub("#{folder}/","")
			next if x == "." || x == ".." || File.directory?(x)
			next unless ["base","desc","aux"].include?(x.split(".")[-1])
			next unless x.include?("sec")
			FileUtils.mv(filename,"#{folder}/"+SectorMover.swap_sector(x,swap_x,swap_y))
		}
	end
end

#=============================================
#**Conversion Test Data
#=============================================

begin
	if ARGV.size != 3
		print "#=============================================\n"
		print "#**ETS2 Sector Mover by Narzew\n"
		print "#**v 1.00\n"
		print "#**08.12.2015\n"
		print "#**http://github.com/narzew/ets2sectormover\n"
		print "#=============================================\n"
		print "#**Usage:\n"
		print "#**ruby SectorMover.rb folder swap_x swap_y\n"
		print "#**folder -> folder containing .desc, .base\n#**and.aux files\n"
		print "#**swap_x -> sector x value to swap (integer)\n"
		print "#**swap_y -> sector y value to swap (integer)\n"
		print "#**For example:\n#**ruby SectorMover.rb europe 200 -100\n"
		print "#**will move europe map 200 sectors east\n#**and 100 sectors north\n"
		print "#=============================================\n"
	else
		folder = ARGV[0]
		raise "Directory not exists" unless Dir.exist?(folder)
		swap_x = ARGV[1].to_i
		swap_y = ARGV[2].to_i
		Dir.mkdir("backup") unless Dir.exist?("backup")
		FileUtils.cp_r(folder,"backup")
		SectorMover.swap_all(folder,swap_x,swap_y)
	end
rescue =>e 
	print "Error: #{e}\n"
end
