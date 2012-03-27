#!/usr/bin/ruby -Ku
# -*- encoding: utf-8 -*-
$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
require "mymatrix/version"
require 'rubygems'
require 'nkf'
require 'logger'
require 'pp'
require 'enumerable_ex' #verbose_each

require 'loader_factory'


if(RUBY_VERSION =~ /1\.[^9]/)
  $KCODE='UTF8'
end

class MyMatrix
	attr_accessor :file, :internal_lf, :mx
	include Enumerable
	#to_t()の際のセパレータ。
	SEPARATOR = "\t"

	# コンストラクタ
	# ====Args
	# _file_ :: オープンするファイル。
	# ====Return
	# 生成されたMyMatrixオブジェクト
	def initialize(file=nil, opts={})
		#内部改行コード。
		@internal_lf = '<br>'
		rnd = rand(9999)
		i = 0
		begin
			@log = Logger.new("MyMatrix_ERR_#{i}.log")
		rescue
			i += 1
			retry
		end
		@log.level = Logger::DEBUG
		@file  = file
		

    @mx = LoaderFactory.load(@file, opts)


		@headers = @mx.shift
		registerMatrix
		return self
	end
	
	# CP932を正しく扱うための変換関数
  # ====Args
  # _str_ :: UTF8文字列
  # ====Return
  # CP932の文字列
	def self.tosjis(str)
		if(RUBY_VERSION =~ /1\.[^9]/)
			#-xは半角カナを全角にするのを抑止するオプション。
			out = NKF.nkf('-W -x -s --cp932', str)
		else
      str = MyMatrix.cp932ize(str)
			out = str.encode("Windows-31J")
		end
		return out
	end
  # 外部ファイルエンコード（CP932）を内部エンコード（UTF8）に変換する
  # ====Args
  # _str_:: CP932 string
  # ====Return
  # UTF8 String
	def self.toutf8(str)
		#out = NKF.nkf('-x -w --cp932', str)
		#入力がShift-jisであるとする。
		out = NKF.nkf('-S -x -w --cp932', str)
		return out		
	end

  # MacOSXのファイルシステムで使われるUTF8-Mac（BOMつきUTF）に変換する
	def self.toUtf8Mac(str)
		out = str
		return out
	end

  #--
  #protected methods
  #++
  protected
  # 現在のヘッダ@headersに合わせてハッシュ@headerHを生成する
  # @headersを書き換えた場合に必ず実行するメソッド
	def registerMatrix
		@headerH = Hash.new
		if(!@headers)
			@headers = []
		end
		@headers.each_with_index do |colName, i|
			@headerH[colName] = i
		end
		fillEmptyCell
	end
  
  # ヘッダ@headers を書き換えた場合など、@headers.sizeとrow.sizeが異なる場合にサイズを揃え
  # 空文字列を入れておく。getValue()した際に必ずStringを返却するための処理。
  # ====※rowを伸ばす方向のみ。@headersを短くした場合の動作は保証できない!
  #
	def fillEmptyCell
		headerSize = getHeaders.size
		@mx.each_with_index do |row, i|
			if(row.size < headerSize)
				(headerSize - row.size).times do |i|
					row << ''
				end
			elsif(row.size > headerSize)
				warn("row is large:#{@file} line #{i+2} / rowSize #{row.size} / headersize #{headerSize}")
				#raise "rowsize error"
			end
		end
	end
	

	def isEnd(row)
		out = true
		row.each do |cell|
			if(cell != "")
				out = nil
				break
			end
		end
		return out
	end

	public
  # カラムの値を配列で返却する
	def getColumn(colName)
		out = []
		@mx.each do |row|
			begin
				out << getValue(row, colName)
			rescue
				raise "#{colName} notfound: #{row}"
			end
		end
		return out
	end
	
  # getColumn のエイリアスメソッド
	def getValues(colName)
		return getColumn(colName)
	end
	#カラムの値を複数指定して、多次元配列を返却するメソッド。
	def getColumns(colNames)
		out = []
		colNames.each do |colName|
			out << getColumn(colName)
		end
		return out
	end

  #
	def getColumnsByMatrix(colNames)
		out = MyMatrix.new
		colNames.each do |colName|
			col = getColumn(colName)
			out.addColumn(colName, col)
		end
		return out
	end
	def val(row, str)
		getValue(row, str)
	end
	
	def getValue(row, str)
		out = nil
		index = @headerH[str]
		if(index)
			out = row[index]
			#お尻のセルでNULLの場合などは、nilが返却されてしまう。なので、''となるようにする。
			if(!out)
				out = ''
			end
			#参照を渡さないためdupする
			out = out.dup
		else
			raise "header not found:#{str} file:#{@file}"
		end
		return out
	end
	alias val getValue
=begin

	def getValues(row, arr)
		out = []
		arr.each do |ele|
			out << getValue(row, ele)
		end
		if(out.size == 0)
			out = nil
		end
		return out
	end

=end

	def setValue(row, str, value)
		if(!row)
			raise 'row is nil'
		end
		index = @headerH[str]
		if(!index)
			addHeaders([str])
		end
		#参照先の値も変更できるように、破壊メソッドを使う。row[@headerH[str]] = valueでは、参照先が切り替わってしまうので、値の置き換えにならない。
		#findなどで取得したrowに対して処理を行う際に必要な変更。
		if(row[@headerH[str]].class == String)
			row[@headerH[str]].sub!(/^.*$/, value)
		else
			#raise('not string error.')
			#todo 強烈なバグな気もするが、例外を回避し値を代入2010年12月15日
			begin
				row[@headerH[str]] = value.to_s
			rescue
				row[@headerH[str]] = ''
			end
		end
	end
	def each
		@mx.each do |row|
			yield(row)
		end
	end
  #未検証
	def reverse
		out = empty
		
		@mx.reverse.each do |row|
			out << row
		end
		return out
	end


	def size
		return @mx.size
	end
	def [](i,j)
		return @mx[i][j]
	end
	
	def [](i)
		return @mx[i]
	end
	
  #未検証
	def +(other)
		out = MyipcMatrix.new
		
		othHeaders = other.getHeaders
		selHeaders = getHeaders
		
		selHeaders.each do |header|
			out.addColumn(header, getColumn(header))
		end
		
		othHeaders.each do |header|
			out.addColumn(header, other.getColumn(header))
		end
		
		return out
	end
	
	def addColumn(header, column)
		pushColumn(header, column)
	end
	def <<(row)
		addRow(row)
	end
	def addRow(row)
		if(row.class != Array)
			row = [row]
		end
		row.size.times do |i|
			if(row[i] == nil)
				row[i] = ''
			end
		end
		
		headerSize = getHeaders.size
		rowSize = row.size
		if(headerSize > rowSize)
			(headerSize - rowSize).times do |i|
				row << ''
			end
		elsif(rowSize > headerSize)
			raise("row size error. headerSize:#{headerSize} rowSize:#{rowSize}")
		end
		@mx << row.dup
	end
	def [](i)
		return @mx[i]
	end
	def []=(key, value)
		@mx[key] = value
	end

  def pushColumn(header, column)
		colPos = @headers.length
		@headers << header
		registerMatrix
		column.each_with_index do |cell, i|
			if(@mx[i] == nil)
				@mx[i] = []
			end
			@mx[i][colPos] = cell
		end
	end
	#使い勝手が良くないので気をつけて使う（todo参照）
  def unShiftColumn(header, column)
		@headers.unshift(header)
		registerMatrix
		column.each_with_index do |cell, i|
			if(@mx[i] == nil)
				@mx[i] = []
			end
			#todo:ヘッダよりでかいrowがある場合バグる。期待していない一番右の値が取れてしまう。
			@mx[i].unshift(cell)
		end
	end
	
	def shiftColumn()
		header = @headers.shift
		column = []
		registerMatrix
		@mx.each do |row|
			column << row.shift
		end
		return header, column
	end

  #複数に分割されたテキストファイルを出力する
	def divide(splitNum)
		lineNum = (@mx.size / splitNum) + 1
		mymxs = []
		tmp = MyMatrix.new
		tmp.file = @file
		tmp.addHeaders(getHeaders)
		@mx.each_with_index do |row, i|
			tmp << row.dup
			if((i+1) % lineNum == 0)
				mymxs << tmp
				tmp = MyMatrix.new
				tmp.addHeaders(getHeaders)
				tmp.file = @file
			end
		end
		mymxs << tmp
		mymxs.each_with_index do |mymx, i|
			p i
			mymx.to_t_with("#{i}")
		end
	end
	#ファイルの中身をSJISにするために使ってる
	def localEncode(v, enc = 's')
		case enc
		when 'u'
			str = MyMatrix.toutf8(v)
		when 's'
			str = MyMatrix.tosjis(v)
		else
			str = MyMatrix.tosjis(v)
		end
	end
	#使い方はto_t()を参照。yield。
	def to_text(outFile)
		outFile = FileIO.encodePath(outFile)
		out = []
		out << @headers
		@mx.each do |row|
			out << row
		end
		begin
			fo = open(outFile, 'wb')
		rescue => e
			p "cannot write file...#{outFile}"
      p e
			sleep(5)
			retry
		end
		out.each_with_index do |row, i|
			if(row == nil)
				warn("line #{i} is nil")
				fo.print("")
			else 
				str = yield(row)
				fo.print(str)
			end
			fo.print("\r\n")
		end
		fo.close
	end
  # テキスト出力する
	def to_t(outFile=nil, opts={})
		if(!outFile)
			outFile = @file
		end
		
		#拡張子の判別
		ext = File.extname(outFile).downcase
		case ext
		when '.csv'
			opts[:separator] ||= ','
			opts[:escape] ||= true
		when '.xls'
			p 'use Tab-Separated-Value text format.'
			outFile = outFile + '.txt'
		when '.xlsx'
			p 'use Tab-Separated-Value text format.'
			outFile = outFile + '.txt'
		else
		 #do nothing
		end
		#デフォルトオプションの設定
		opts[:enc] ||= 's'
		opts[:escape] ||= false
		opts[:separator] ||= SEPARATOR
		
		to_text(outFile) do |row|
			orow = []
			if(opts[:escape])
				row.each do |cell|
					orow << myescape(cell)
				end
			else
        row.each do |cell|
   				orow << cell.to_s.gsub(/[#{opts[:separator]}\r\n]/, '')
        end
			end
			
			begin
				str = localEncode(orow.join(opts[:separator]), opts[:enc])
			rescue Encoding::UndefinedConversionError
        orow.each do |ele|
          begin
            localEncode(ele, opts[:enc])
          rescue
            raise "encode error.#{ele}\n(#{orow})"
          end
        end

				@log.debug(row.join(opts[:separator]))
			end
			str
		end
	end
	def myescape(cell)
		o = cell.to_s.dup
		o.gsub!(/"/, '""')		
		if o =~ /[",']/
			#'
			o = "\"#{o}\""
		end
		return o
	end
  # 読み込んだファイル名にpostfixを付与してテキストファイル出力する
	def to_t_with(postfix="out", opts={})
    opath = MyMatrix.make_path(@file, {:ext=>nil, :postfix=>postfix})
		to_t(opath, opts)
		return opath
	end

  #CSV出力する。ダブルクオーテーションやカンマをエスケープする。
	def to_csv(outFile)
		to_t(outFile, {:separator=>',', :escape=>true})
	end
  
  #ヘッダのコピーを返却する
	def getHeaders
		out = @headers.dup
		return out
	end
  #ヘッダを置き換える
	def replaceHeader(before, after)
		@headers[@headerH[before]] = after
		registerMatrix
	end

  # colNameの値がvalueの行のうち先頭のものを返却する。todo:名称がよくない。
	def index(colName, value)
		out = nil
		col = getColumn(colName)
		col.each_with_index do |cell, i|
			if(value == cell)
				out = i
				break
			end
		end
		return out
	end

  # colnameの値がvalueの行のもののインデックス値を配列で返却する。todo:名称がよくない。
	def searchIndexes(colName, value)
		out = []
		col = getColumn(colName)
		col.each_with_index do |cell, i|
			if(value == cell)
				out << i
			end
		end
		return out
	end

  # colnameの値がvalueの行のrowを配列で返却する。todo:名称がよくない。
	def search(colName, value)
		indexes = []
		col = getColumn(colName)
		col.each_with_index do |cell, i|
			if(value == cell)
				indexes << i
			end
		end
		out = self.empty
		indexes.each do |index|
			out << @mx[index]
		end
		return out
	end
  # ヘッダを追加する(配列)
	def addHeaders(aheaders)
		@headers.concat(aheaders).uniq!
		
		registerMatrix
	end

  # ヘッダを追加する
	def addHeader(key)
		addHeaders([key])
	end

  #行数を返却する 
	def size
		return @mx.size
	end
	
  #未検証。「要素の重複判定は、Object#eql? により行われます。」http://www.ruby-lang.org/ja/old-man/html/Array.html#uniq
	def uniq!
		@mx.uniq!
	end
	
	def shift
		return @mx.shift
	end
	def unshift(var)
		return @mx.unshift(var)
	end
	def pop
		return @mx.pop
	end
	def push(var)
		return @mx.push(var)
	end
	def delete_at(pos)
		@mx.delete_at(pos)
	end

  #未検証。「要素を順番にブロックに渡して評価し、その結果が真になった要素を すべて削除します。」
  def delete_if
		out = @mx.delete_if do |row|
			yield(row)
		end
		@mx = out
	end
	def delete(v)
		@mx.delete(v)
	end
	#ブロックがTrueになる、配列（参照）を返却するメソッド
	def find
		#todo rowsを返却するのと、Mymatrxixを返却するのとどっちがイイのか。。
		rows = []
		@mx.each do |row|
			if(yield(row))
				rows << row.dup
			end
		end
		return rows
	end
	
  #headersに記載の
	def select(headers)
		out = self.class.new
			headers.each do |header|
			out.addColumn(header, getColumn(header))
		end
		out.file = @file
		return out
	end
	
  #fromColName => toColNameのハッシュを作成する。
  #fromColNameの値が同じだとtoColNameが上書きされるので使いにくいと思われる。
	def makeHash(fromColName, toColName)
		out = Hash.new
		@mx.each do |row|
			from = getValue(row, fromColName)
			to = getValue(row, toColName)
			out[from] = to
		end
		return out
	end
	
	#colnameがキーのハッシュを作る。valueはrowの配列。
	def makeKey(colname)
		out = {}
		self.each do |row|			
			key = self.val(row, colname)
			if(out[key] == nil)
				out[key] = []
			end
			out[key] << row
		end
		return out
	end
	
	#MyipcMatrixとの互換性のため。getValueのエイリアス
	def getCrrValue(row, str)
    p 'this class is not MyipcMatrix.'
		getValue(row, str)
	end
	
	def concatCells(headers, colname)
		addHeaders([colname])
		@mx.each do |row|
			val = []
			headers.each do |header|
				val << getValue(row, header)
			end
			setValue(row, colname, val.join('_').gsub(/_+/, '_'))
		end
	end

  #読み込んだファイルのパスを返却する
	def getPath
		return @file
	end
  #ファイルパスを設定する。 to_tを引数なしで使うと、設定したパスにファイルが生成される。
	def setPath(path)
		@file = path
	end

  # strを含む（/#{str}/）ヘッダ名を配列で返却する。
	def searchHeader(str)
		out = []
		getHeaders.each do |header|
			if(header =~ /#{str}/)
				out << header
			end
		end
	end
	
	#n分割した配列を返却する
	def devide(n)
		out = []
		mx = @mx.dup
		eleSize = mx.size/n
		n.times do |i|
			o = self.empty
			eleSize.times do |j|
				o << mx.shift
			end
			out << o
		end
		#@mx.size%n分余ってるので、追加
		mx.each do |ele|
			out[n-1] << ele
		end
		return out
	end
	#compareHeaderの値の中に、valuesに書かれた値があったら、targetHeaderにフラグを立てる
	def addFlg(targetHeader, compareHeader, values, flgValue='1')
		compares = getColumn(compareHeader)
		values.each do|value|
			i = compares.index(value)
			if(i)
				setValue(@mx[i], targetHeader, flgValue)
			else
				#raise "VALUE NOT FOUND:#{value}"
			end
		end
	end

	def without(regexp_or_string)
    if(regexp_or_string.class == String)
      regexp = /#{regexp_or_string}/
    else
      regexp = regexp_or_string
    end
		newHeaders = []
		@headers.each do |header|
			if(header =~ regexp)
			else
				newHeaders << header
			end
		end
		out = select(newHeaders)
		return out
	end
	
  #行が空（ヘッダはそのまま）のコピーを返却する
	def empty
		out = self.dup
		out.empty!
		return out
	end

  #selfの行を空にする
	def empty!
		@mx = []
    return self
	end
	def fill(rows)
		rows.each do |row|
			self << row
		end
		return self
	end
		
	#行番号を付与する
	def with_serial(headerName = 'No.')
		out = self.empty
		out.addHeaders([headerName], 1)
		self.each_with_index do |row, i|
			no = i + 1
			newRow = [no].concat(row)
			out << newRow
		end
		return out
	end
	
 
	def count(header, value)
		out = 0
		arr = getColumn(header)
		arr.each do |ele|
			if(ele =~ /#{value}/)
				out += 1
			end
		end
		return out
	end
	#全件カウントして、[value, count] という配列に格納する
	def countup(header)
		out = []
		values = getColumn(header).uniq
		values.each do |value|
			out << [value, self.count(header, value)]
		end
		return out
	end
	def getDoubles(arr)
		doubles = arr.select do |e|
		 arr.index(e) != arr.rindex(e)
		end
		doubles.uniq!
		return doubles
	end
	
	def filter(header, value)
		out = empty
		@mx.each do|row|
			v = getValue(row, header)
			if(v == value)
				out << row
			end
		end
		return out
	end
	#配列と引き算とかする際に使われる。
	def to_ary
		arr = []
		@mx.each do |row|
			#arr << row.dup
			arr << row
		end
		return arr
	end
	def to_s
		out = ''
		@mx.each do |row|
			out = out + row.to_s + "\n"
		end
		return out
	end
	def to_s_with_header
		out = self.getHeaders.to_s + "\n"
		out = out + self.to_s
	end
	def concat(mx, opt={})
		notfoundHeaders = []
		mx.each do |row|
			o = []
			mx.getHeaders.each do |head|
				begin
					self.setValue(o, head, mx.getValue(row, head))
				rescue => e
					#p e
					if(opt[:loose]==true)
						self.addHeaders([head])
						#p "#{head} added"
						retry
					else
						notfoundHeaders << head
					end
				end
			end
			self << o
		end
		if(notfoundHeaders.size > 0)
			raise "notfoundHeader : #{notfoundHeaders.uniq.join(',')}"
		end
		return self
	end
	def concatFile(file, opt={})
		#p file
		mx = MyMatrix.new(file)
		self.concat(mx, opt)
		return self
	end
	#フォルダ内ファイルの結合。絶対パスを指定する
	def concatDir(dir)
		dir = File.expand_path(dir)
		Dir.entries(dir).each do |ent|
			if(ent =~ /^\./)
			else
				#p ent

				file = dir + '/' + ent
				#p "concat:#{file}"
				nmx = MyMatrix.new(file)
				self.concat(nmx)
			end
		end

	end
=begin
  def concat!(mx)
		o = self.concat(mx)
		self = o
		return self
	end
	def concatFile!(file)
		o = self.concatFile(file)
		self = o
		return self
	end
=end
	def flushCol(colname)
		@mx.each do |row|
			self.setValue(row, colname, '')
		end
		return self
	end
	def sortBy(colname, reverse=false)
		sortmx = []
		self.each do |row|
			key = self.getValue(row, colname)
			sortmx << [key, row]
		end
		sortmx.sort!
		self.empty!
		sortmx.each do |keyrow|
			self << keyrow[1]
		end
		return self
	end
	def dupRow(row, destmx, destrow, headers)
		headers.each do |head|
			val = self.getValue(row, head)
			destmx.setValue(destrow, head, val)
		end
		return destrow
	end
	def setSame(head, headValue, hash)
		idxs = self.searchIndexes(head, headValue)
		idxs.each do |idx|
			hash.each_pair do |key, value|
				self.setValue(@mx[idx], key, value)
			end
		end		
	end
	
	#都道府県市区町村コードの桁そろえ
	#Excelで先頭の0が落ちて桁が変わるため
	def correctCityCodes!(colname = '都道府県市区町村コード')
		self.each do |row|
			code = self.val(row, colname)
			if(code.length == 4)
				self.setValue(row, colname, sprintf("%05d", code))
			elsif(code.length == 5)
				#correct
			else
				raise "Citycode length error. '#{code}'"
			end
		end
		return self
	end
	
	#末尾空白の削除
	def delEndSp!
		self.each do |row|
			self.getHeaders.each do |head|
				val = self.val(row, head)
				if(val =~ /(.*)[　 ]$/)
					self.setValue(row, head, $1)
				end
			end
		end
		return self
	end
	#半角カタカナの全角化
	def twoByteKana!
		self.each do |row|
			self.getHeaders.each do |head|
				val = self.val(row, head)								
				#if(val =~ /[－～]/)
				if(val =~ /[－]/)
					#p "#{self.file} #{val}"
					next
				end
				#nval = Kconv.kconv(val, Kconv::UTF8, Kconv::UTF8)
				#nval = NKF.nkf('-W -w -x --cp932', val)

				nval = NKF.nkf('-W -w', val)

				if(val!=nval)
					#p "#{val}=>#{nval}"
				end
				self.setValue(row, head, nval)
			end
		end
		return self
	end
  #CP932範囲外の文字コードを変換する関数。ruby1.9の正規表現（鬼車）のため、1.8では使えない。
	def self.cp932ize(str)
		out = str.dup
		cases = [
			#['−', '―'], #MINUS SIGN(U+2212) to FULLWIDTH HYPHEN-MINUS(U+2015)(windows)
			#↑仕様としては上記が正しいが、運用上MINUS SIGN(U+2212) は FULLWIDTH HYPHEN-MINUS(U+FF0D)に変換する
			#キー入力時にMacとWindowsで同じ文字コードとなることが望ましいため。
			
			['〜','～'], #WAVE DASH (U+301C) to FULLWIDTH TILDE(U+FF5E)(windows)
			['‖','∥'], #DOUBLE VERTICAL LINE (U+2016, "‖") を PARALLEL TO (U+2225, "∥") に
			['—', '―'], #EM DASH (U+2014, "—") を HORIZONTAL BAR (U+2015, "―") に
			#以下、キー入力を想定した変換。
			['ー', 'ー'], #MacのハイフンF7(google ime)→Windows(googleime)：同じ
			['ｰ', 'ｰ'], #MacのハイフンF8(google ime)→Windows(googleime)：同じ
			['−', '－'], #MacのハイフンF9[−](google ime)→Windows[－](googleime)：違う。MINUS SIGN(U+2212) to FULLWIDTH HYPHEN-MINUS(U+FF0D)
			['-', '-'], #MacのハイフンF10(google ime)→Windows(googleime)：同じ
      #ユニコード固有文字:ノーブレークスペース
      ['[\u00A0]', ' '],
      #yen
      ['[\u00A5]', '￥'],
      # éとè:eの上に´と`
      ['[\u00E9]', 'e'],['[\u00E8]', 'e'],
      #spaces
      ['[\u2000]', ' '],['[\u2001]', ' '],['[\u2002]', ' '],['[\u2003]', ' '],['[\u2004]', ' '],['[\u2005]', ' '],['[\u2006]', ' '],['[\u2007]', ' '],['[\u2008]', ' '],['[\u2009]', ' '],['[\u200A]', ' '],['[\u205F]', ' ']
			]
		cases.each do |c|
			out.gsub!(/#{c[0]}/, c[1])
		end
		return out
	end
	
=begin	
	def to_xls(opts)
		if(opts[:out] =~ /.xls$/)
		else
			raise "not outfile"
		end
		opts[:template] ||= opts[:out]
		
		opts[:offset_r] ||= 0
		opts[:offset_c] ||= 0

		xl = Spreadsheet.open(encodePath(opts[:template]), 'r')
		sheet = xl.worksheet(0)
		@headers.each_with_index do |head, i|
			ab_row = opts[:offset_r]
			ab_col = opts[:offset_c] + i
			sheet[ab_row, ab_col] = head			
		end
		self.each_with_index do |row, i|
			row.each_with_index do |cell, j|
				ab_row = opts[:offset_r] + i + 1
				#↑ヘッダ分1オフセット 
				ab_col = opts[:offset_c] + j				
				sheet[ab_row, ab_col] = cell
			end
		end
		
		xl.write(opts[:out])
		
	end
=end
	#Arrayっぽく使うためのメソッド。内部の@mx.first
	def first
		@mx[0]
	end
	#Arrayっぽく使うためのメソッド。内部の@mx.last
	def last
		out = @mx[self.size-1]
	end
	def empty?
		@mx.empty?
	end
  #num文字以上の項目をnum文字に丸める
  def cutOff(head, num)
    self.each do |row|      
      v = self.val(row, head)
      if(v =~ /(.{#{num}})/)
        self.setValue(row, head, $1)
      end
    end
	end
  def self.make_path(path, opts={ })
    # opath = makepath(@file, {:ext=>nil, :postfix=>postfix})
		dir = File.dirname(path)
    ext = opts[:ext]
		ext ||= File.extname(path)
    postfix = opts[:postfix].to_s

		basename = File.basename(path, ".*")
		opath = (FileIO.encodePath("#{dir}/#{basename}_#{postfix}#{ext}"))
  end
end
