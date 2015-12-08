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
		#print "#{filename} => #{result}\n"
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
			newfilename = "#{folder}/"+SectorMover.swap_sector(x,swap_x,swap_y)
			#FileUtils.mv(filename,"#{folder}/"+SectorMover.swap_sector(x,swap_x,swap_y))
		}
	end
end

#=============================================
#**Conversion Test Data
#=============================================

begin
	
	#SectorMover.swap_all("bolivia3.1",400,400)
	sec_a = "sec+0004-0005.desc"
	sec_b = "sec-0017+0125.aux"
	enc_a = SectorMover.swap_sector(sec_a,16,-5)
	enc_b = SectorMover.swap_sector(sec_b,-19,800)
	dec_a = SectorMover.swap_sector(enc_a,-16,5)
	dec_b = SectorMover.swap_sector(enc_b,19,-800)
	
	#cor_a = SectorMover.swap_sector(SectorMover.swap_sector(sec_a,200,200),-200,-200)
	#cor_b = SectorMover.swap_sector(SectorMover.swap_sector(sec_b,-300,-300),300,300)
	
	puts "SEC A: #{sec_a}"
	puts "SEC B: #{sec_b}"
	puts "ENC A: #{enc_a}"
	puts "ENC B: #{enc_b}"
	puts "DEC A: #{dec_a}"
	puts "DEC B: #{dec_b}"
	if sec_a == dec_a
		puts "SEC A CONVERT SUCCESS"
	else
		puts "SEC A CONVERT FAILED"
	end
	if sec_b == dec_b
		puts "SEC B CONVERT SUCCESS"
	else
		puts "SEC B CONVERT FAILED"
	end
	
	#puts SectorMover.swap_sector("sec+0004-0005.desc", 200, 200)
	#puts SectorMover.swap_sector("sec+0004-0005.desc", -200, -200)
end

=begin
	if ARGV.size != 3
		print "Sector Mover v 1.00 by Narzew\n"
		print "Usage: SectorMover.rb folder swap_x swap_y\n"
	else
		folder = ARGV[0]
		swap_x = ARGV[1].to_i
		swap_y = ARGV[2].to_i
		Dir.mkdir("backup") unless Dir.exist?("backup")
		FileUtils.cp_r(folder,"backup")
	end
=end
