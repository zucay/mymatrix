# -*- coding: utf-8 -*-
require 'file_io'
class LoaderCsv < FileIO
  def self.makeMatrix(file, opts=nil)
    opts ||= {}
    opts[:offset] ||= 0
    opts[:encode] ||= 'Windows-31J'

  #CSV読み込みメソッド
		#1.9系ではFasterCSVを使えない
		if(RUBY_VERSION =~ /1\.[^9]/)
			#1.8以下の場合
			require 'fastercsv'
			csv = FasterCSV
		else
			#1.9以上の場合
			require 'csv'
			#Encoding.default_external = opts[:encode]
			csv = CSV
		end
		out = []
		i= 0
		syspath = self.encodePath(file)
		#csv.foreach(syspath, {:row_sep => "\r\n", :encoding => opts[:encode]}) do |row|
    csv.foreach(syspath, {:encoding => opts[:encode]}) do |row|
			if(opts[:offset])
				if(opts[:offset] < i)
					next
				end
			end
			#「1,300台」などカンマが使われている場合、「"1,300台"」となってしまうので、カンマを無視する
			newRow = []
			row.each do |cell|
				cell = cell.to_s
				cell ||= ''
        p cell
				#cell = MyMatrix.toutf8(cell)
				#cell = cell.gsub(/^\"/, "")
				#cell = cell.gsub(/\"$/, "")
				#"
				newRow << cell
			end
			out << newRow
			i += 1
		end
		return out


  end
end
