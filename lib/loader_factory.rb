# -*- coding: utf-8 -*-
require 'loader_xls'
require 'loader_csv'
require 'loader_txt'
class LoaderFactory
  def self.load(file, opts)
    mx = []
    if(file =~ /\.xls$/)
			mx = LoaderXls.makeMatrix(file, opts)
		elsif(@file =~ /(\.tsv|\.txt|\.TSV|\.TXT)/)
			mx = LoaderTxt.makeMatrix(file, opts)
		elsif(file =~ /(\.csv|\.CSV)/)
			mx = LoaderCsv.makeMatrix(file, opts)
		elsif(file == nil)
		else
			#デフォルトはTSVで読み込むようにする。
			mx = LoaderTxt.makeMatrix(file, opts)
		end
    mx = self.clean(mx)
    return mx
  end
  def self.clean(mx)
		#@mxの末尾に空レコードが入っていたら、その空白を削除
		while(mx[mx.size-1] && mx[mx.size-1].join == '')
			mx.pop
		end
		if(mx.size == 0)
			mx = []
		end
    return mx
  end
end
