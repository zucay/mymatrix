# -*- coding: utf-8 -*-
require 'file_io'
require 'spreadsheet'
class LoaderXls < FileIO
  def self.makeMatrix(file, opts={ })
    # xls読み込みメソッド
		if(opts)
			offset = opts[:offset]
      sheet = opts[:sheet]
		end
		offset ||= 0
    sheet ||= 0
    
		out = []
		#todo xlsFileがなかったら作成
		path = self.encodePath(file)
		xl = Spreadsheet.open(path, 'rb')
    sheet = xl.worksheet(sheet)
		rowsize = sheet.last_row_index
		(rowsize+1-offset).times do |i|
			row = sheet.row(i+offset)
			orow = []
			row.each do |ele|
				#様々な型で値が入っている。改行も入っている
				if(ele.class == Float)&&(ele.to_s =~ /(\d+)\.0/)
					ele = $1
				end
				if(ele.class == Spreadsheet::Formula)
					ele = ele.value
				end
				if(ele == nil)
					ele = ''
				end
				ele = ele.to_s.gsub(/\n/, '<br>')
				orow << ele
			end
			out << orow
		end
		return out
  end
end
