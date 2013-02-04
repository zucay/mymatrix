# -*- coding: utf-8 -*-
class FileIO
  # ファイル書き込み時、パス文字列のエンコードを変換してシステムに返却するためのメソッド
	def self.encodePath(path)
		case self.filesystem
		when 'u' # Linux Utf-8
			#utf8=>utf8なので何もしない
			path
		when 's' # Windows Shift-JIS(CP932)
			path = MyMatrix.tosjis(path)
		when 'm' # Mac utf8(UTF8-Mac)
			path = MyMatrix.toUtf8Mac(path)
    else
      path
		end
	end
  # ファイル読み込み時、パス文字列のエンコードをUTF8に変換して内部保持する為のメソッド。
  # Windowsからファイルを受け取る場合、ShiftJisで文字列が渡ってくるため。
  def self.readPath(path)
    case self.filesystem
    when 's'
      MyMatrix.toutf8(path)
    else
      path
    end
  end

  # ファイルシステムを判定するメソッド。
  def self.filesystem
 		#platform check
		if(RUBY_PLATFORM.downcase =~ /mswin(?!ce)|mingw|cygwin|bccwin/)
			filesystem = 's' # Windows Shift-JIS(CP932)
		elsif(RUBY_PLATFORM.downcase =~ /darwin/)
			filesystem = 'm' # Mac utf8(UTF8-Mac)
		elsif(RUBY_PLATFORM.downcase =~ /linux/)
			filesystem = 'u' # Linux Utf-8
		else
			filesystem = 'u'
		end
    return filesystem
  end
end
