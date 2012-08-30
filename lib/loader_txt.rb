# -*- coding: utf-8 -*-
require 'file_io'
class LoaderTxt < FileIO
  def self.makeMatrix(file, opts=nil)
    #TSV: tab separated value 読み込みメソッド
    opts ||= {}
    opts[:sep] ||= "\t"
    opts[:offset] ||= 0
    opts[:encode] ||= "Windows-31J"
		out = []
    epath = encodePath(file)
		if(!File.exist?(epath))
			open(epath, 'w') do |fo|
				fo.print("\n\n")
			end
		end
    path = self.encodePath(file)
		fi = open(path, "r:#{opts[:encode]}")
		if(opts[:offset])
			opts[:offset].times do |i|
				fi.gets
			end
		end
		opts[:sep]||="\t"
		fi.each do |line|
		  
			row = MyMatrix.toutf8(line).chomp.split(/#{opts[:sep]}/)
			#「1,300台」などカンマが使われている場合、「"1,300台"」となってしまうので、カンマを無視する
			newRow = []
			row.each do |cell|
				stri = cell.dup
				stri.gsub!(/^\"(.*)\"$/, '\1')
				#"
				stri.gsub!(/""/, '"')
				newRow << stri
			end
			out << newRow
		end
		fi.close
		return out


  end
end
