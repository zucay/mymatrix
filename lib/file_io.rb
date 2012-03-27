# -*- coding: utf-8 -*-
class FileIO
  # ファイルオープン時、パス文字列のエンコードを変換してシステムに返却するためのメソッド
	def self.encodePath(path)
		case self.filesystem
		when 'u'
			#utf8=>utf8なので何もしない
			#path = MyMatrix.toutf8(path)
			#path.encode('UTF-8')
			path
		when 's'
			path = MyMatrix.tosjis(path)
			#path.encode('Windows-31J')
		when 'w'
			path = MyMatrix.tosjis(path)
			#path.encode('Windows-31J')
		when 'm'
			path = MyMatrix.toUtf8Mac(path)
		end
	end
  def self.filesystem
 		#platform check
		if(RUBY_PLATFORM.downcase =~ /mswin(?!ce)|mingw|cygwin|bccwin/)
			filesystem = 's'
		elsif(RUBY_PLATFORM.downcase =~ /darwin/)
			filesystem = 'm'
		elsif(RUBY_PLATFORM.downcase =~ /linux/)
			filesystem = 'u'
		else
			filesystem = 'u'
		end
    return filesystem
  end
end
