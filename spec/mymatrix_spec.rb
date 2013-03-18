# -*- encoding: utf-8 -*-
require 'mymatrix'
require 'rspec'

describe MyMatrix do
  before :all do
    if(RUBY_VERSION =~ /1\.[^9]/)
    else
      Encoding.default_external = 'Windows-31J'
    end
  end
  
  it '４行と4行のデータをconcatFileで結合すると8行になること' do
    @mx = MyMatrix.new('spec/line4.xls')
    @mx.concatFile('spec/line4.xls')
    @mx.size.should == 8
  end
  it 'concatが正しく出来ていること' do
    @mx = makeSample
    @mx.concat(makeSample)
    @mx[4].should == ['4', '6', '8']
    @mx.size.should == 8
  end
  
  it 'newして保存すると、適切な値が保存されていること' do
    @mx = MyMatrix.new
    @mx.addHeaders(%w[genre name])
    row = %w[furuit banana]
    @mx << row
    @mx.size.should == 1
    @mx[0].should == row
  end
=begin
  it 'sortされること' do
    @mx = MyMatrix.new('spnc/110619.xls')
    @mx = @mx.sortBy('要確認').reverse
    @mx.each do |row|
      #p @mx.val(row, '要確認')
    end
    @mx.val(@mx[0], '要確認').should == '★'
    @mx.val(@mx[15], '要確認').should == '★'
    @mx.val(@mx[16], '要確認').should == ''
    @mx.val(@mx[17], '要確認').should == ''
  end
=end
  
  it 'concatFileに存在しないファイルを指定したら例外発生すること' do
    @mx = MyMatrix.new('spec/line4.xls')
    proc{
      @mx.concatFile('hogehogehogefhoeg.xls')
    }.should raise_error
  end
  
  it '<<rowした場合、各要素にnilが入らないこと' do
    @mx = MyMatrix.new
    @mx.addHeaders(%w[a b c d])
    row = []
    @mx.setValue(row, 'c', 'hoge')
    @mx << row
    @mx[0][0].should == ''
    @mx[0][2].should == 'hoge'
    @mx[0][3].should == ''
  end
  
  it 'XLSで表示されている通りの値がStringとして取得できること' do
    @mx = MyMatrix.new('spec/std_shoshiki.xls')
    @mx[0][0].should == '標準書式での数値の扱い'
    @mx[0][0].class.should == String
    
    @mx[0][1].should == '1'
    @mx[0][1].class.should == String
    
    @mx[0][2].should == '2'
    @mx[0][2].class.should == String

    @mx[0][3].should == '3.3'
    @mx[0][3].class.should == String
  end
  
  it 'ファイルを読み込む際に、末尾の空行を削除して読み込むこと' do
    out = MyMatrix.new('spec/line4.txt')
		out.size.should == 4
  end
  it '日本語ファイル名に対応していること（Mac環境を想定）' do
    filename = 'spec/ダクテン（だくてん）つきファイル.txt'
    mx = makeSample()
    mx.to_t(filename)
    
    mx = MyMatrix.new(filename)
		mx.val(mx[0], 'b').should == '6'
    
  end
  it 'カンマを含むcsvファイルが読めること' do
    pending
    s = MyMatrix.new
    mx = makecsv
    
    mx[0][0].should == ''
    mx[1][0].should == 'ダブル"クオーテーション'
    mx[1][1].should == 'カン,マ'
    mx[1][2].should == 'aaa'
  end
  it 'UTF-8形式のcsvファイルが読めること' do
    mx = makecsv_utf
    mx[0][0].should == ''
    mx[0][2].should == '大阪'
    mx.val(mx[0], 'b').should == '奈良'
  end
  it 'tsvファイルを読めること' do 
    mx = MyMatrix.new('spec/jptest.txt')
    mx.getHeaders[0].should == '日本語ヘッダ１'
    mx[0][0].should == '値１value1'
  end
  
  it 'concatDirでフォルダ内ファイルを全て結合できること' do
    mx = MyMatrix.new
    mx.concatDir('spec/for_concat')
    mx.size.should == 16
  end
  
  it '存在しないカラムを取得しようとしたら例外が発生すること' do
    mx = MyMatrix.new
    row = []
    proc{
      mx.val(row, 'foobar')
    }.should raise_error
  end

  it 'ヘッダが先頭にないファイルも読み込めること' do		
    mx = MyMatrix.new('spec/offset.txt', {:offset=>2})
    mx.getHeaders.should == %w[A B C D]
    mx[0][0].should == 'a1'
    mx.val(mx[1], 'D').should == 'd2'
  end
  it 'ヘッダが先頭にないファイルに書き出せること' do
    pending('必要になったら実装する')
    mx = makeSample()
    mx.to_xls({:template => 'spec/template.xls', :out=>'spec/out.xls', :offset_r => 3, :offset_c =>1})

    mx = MyMatrix.new('spec/out.xls')
    mx.val(mx[0], 'P-a').should == 'iti'
    mx[3][1].should == 'a'
    mx[4][1].should == '4'
  end
  it 'xls形式で書き出せること' do 
    mx = MyMatrix.new('spec/template.xls')
    mx.setValue(mx[0], 'P-b', 'foo')

    mx.to_xls('spec/out.xls')

    mx = MyMatrix.new('spec/out.xls')
    mx.val(mx[0], 'P-a').should == 'iti'
    mx.val(mx[0], 'P-b').should == 'foo'
  end
  it '同じシーケンスIDに同一の値をsetできること' do
    mx = MyMatrix.new()
    mx.addHeaders(%w[シーケンス 名称 情報])
    mx << ['1', 'apple', 'begi']
    mx << ['11', 'tomato' ,'begi']
    mx << ['1', 'greenapple', 'begi']
    mx.setSame('シーケンス', '1', {'情報'=>'fruit'})
    mx[0][0].should == '1'
    mx[0][2].should == 'fruit'
    mx[1][2].should == 'begi'
    mx[2][2].should == 'fruit'		
  end
  
  it 'ただしくハッシュオブジェクトが作成されること' do
    mx = MyMatrix.new()
    mx.addHeaders(%w[シーケンス 名称 情報])
    mx << ['1', 'apple', 'begi']
    mx << ['11', 'tomato' ,'begi']
    mx << ['1', 'greenapple', 'begi']
    
    hash = mx.makeKey('シーケンス')
    hash['1'].size.should == 2
    hash['1'][1].should == ['1', 'greenapple', 'begi']
    hash['11'][0].should == ['11', 'tomato' ,'begi']				
  end
  
  it 'ヘッダの名称変更が正しく行えること' do
    mx = makeSample
    mx.replaceHeader('a', 'aaa')
    mx.replaceHeader('b', 'bbb')
    mx.getHeaders[0].should == 'aaa'		
    mx.getHeaders[1].should == 'bbb'
    mx.getHeaders.size.should == 3
  end
  it 'カンマをエスケープしてcsvファイルを出力できること' do
    pending
    mx = makecsv
    mx.to_csv('spec/csv_test.csv')
    fi = open('spec/csv_test.csv')
    str = fi.gets
    str.should ==  MyMatrix.tosjis("a,b,c\r\n")
    str = fi.gets
    str.should ==  MyMatrix.tosjis(",奈良,大阪\r\n")
    str = fi.gets
    str.should ==  MyMatrix.tosjis("\"ダブル\"\"クオーテーション\",\"カン,マ\",aaa\r\n")		
    fi.close		
  end
  it '市町村コードの桁が揃えられること' do
    mx = MyMatrix.new
    mx.addHeaders(['都道府県市区町村コード'])
    mx << ['1100']
    mx.correctCityCodes!
    mx[0][0].should == '01100'
  end
  it '開き直してもCP932範囲内の文字コードは変わらないこと' do
    testcases = [
                 ['－', '－'], #変更なし：FULLWIDTH HYPHEN-MINUS(U+FF0D)
                 ['～', '～'], #変更なし：FULLWIDTH TILDE(U+FF5E)
                 ['ｱ', 'ｱ'], #1byte kana
                 ['①', '①'] #windows CP932 only
		]
    translationCheck(testcases)
  end
  it 'CP932範囲外の記号は、CP932範囲の記号に変換されること' do 
    testcases = [
                 #['1−', '1―'], #MINUS SIGN(U+2212) to FULLWIDTH HYPHEN-MINUS(U+2015)(windows)
                 #↑仕様変更のためコメントアウト
                 
                 ['2〜','2～'], #WAVE DASH (U+301C) to FULLWIDTH TILDE(U+FF5E)(windows)
                 ['3‖','3∥'], #DOUBLE VERTICAL LINE (U+2016, "‖") を PARALLEL TO (U+2225, "∥") に
                 ['4—', '4―'], #EM DASH (U+2014, "—") を HORIZONTAL BAR (U+2015, "―") に
                 #キー入力を想定した変換。
                 ['5ー', '5ー'], #MacのハイフンF7(google ime)→Windows(googleime)：同じ
                 ['6ｰ', '6ｰ'], #MacのハイフンF8(google ime)→Windows(googleime)：同じ
                 ['7−', '7－'], #MacのハイフンF9(google ime)→Windows(googleime)：違う。MINUS SIGN(U+2212) to FULLWIDTH HYPHEN-MINUS(U+FF0D)
                 ['8-', '8-'], #MacのハイフンF10(google ime)→Windows(googleime)：同じ
		]
    if(RUBY_VERSION =~ /1\.[^9]/)
      pending
    else
      translationCheck(testcases)
    end
  end
  
  it '半角カナを全角に出来ること' do
    testcases = [
                 ['-', '-'], #hyphen
                 ['ﾌｧﾐﾘｰﾏｰﾄ', 'ファミリーマート'], #ハイフンを長母音に変換	
                 ['03-3352-7334', '03-3352-7334'],
                 ['ａｂｃ０', 'ａｂｃ０'], #全角英数はそのまま
                 ['abc', 'abc'] #半角英数もはそのまま
		]
    translationCheck(testcases) do |mx|
      mx.twoByteKana!
    end
  end
  it '拡張子によって保存形式が変わること' do
    mx = makeSample()
    mx.to_t('spec/test.csv')
    fi = open('spec/test.csv')
    str = fi.gets
    str.should ==  MyMatrix.tosjis("a,b,c\r\n")
    
    mx.to_t('spec/test.tsv')
    fi = open('spec/test.tsv')
    str = fi.gets
    str.should ==  MyMatrix.tosjis("a\tb\tc\r\n")
    
    mx.to_t('spec/test.txt')
    fi = open('spec/test.txt')
    str = fi.gets
    str.should ==  MyMatrix.tosjis("a\tb\tc\r\n")
    
  end
  it 'セルの中に改行コードが入っていた場合、to_tしたら削除されること' do
    mx = makeSample
    mx[0][1] = mx[0][1] + "\r"
    mx.to_t('spec/test.txt')
    fi = open('spec/test.txt')
    str = fi.gets
    str = fi.gets
    str.should ==  MyMatrix.tosjis("4\t6\t8\r\n")
  end
  it '長すぎる文字列があったらcutOffで短くできること' do
    mx = makeSample
    mx[0][0] = '01234567890'
    mx[0][1] = ''    
    str = mx[0][2].dup    
    mx.cutOff('a', 4)
    mx[0][0].should == '0123'
    mx[0][1].should == ''    
    mx[0][2].should == str    
  end
  
  it 'SJIS範囲外の漢字が含まれるデータをテキスト出力する時は例外を発生させること' do
    pending('実装が難しいためペンディング')
    mx = MyMatrix.new
    mx.addHeaders(['str'])
    mx << ['盌']
    Proc {
      mx.to_t('spec/test.txt')
    }.should raise_error
  end
  it 'ヘッダが半角でも対応できること' do
    mx = makeHankakuSample
    mx.val(mx[0], '削除ﾌﾗｸﾞ').should == '4'
  end

  it 'to_tのオプション:remove_empty_row をtrueにすると、空行を出力しないこと' do
    output_mx = makeEmptySample
    output_mx.to_t('spec/test.txt', {:remove_empty_row => true })
    fi = File.open('spec/test.txt')
    fi.count.should == 2
  end

end
def translationCheck(testcases)
  mx = MyMatrix.new
  mx.addHeaders(['カラム'])
  testcases.each do |mycase|
    mx << [mycase[0]]
  end
  if(block_given?)
    yield(mx)
  end
  mx.to_t('spec/test.txt')
  mx = MyMatrix.new('spec/test.txt')
  
  testcases.each_with_index do |mycase, i|
    mx[i][0].should == mycase[1]
  end
end

def makeSample
  out = MyMatrix.new()
  out.addHeaders(['a', 'b', 'c'])
  out << ['4', '6', '8']
  out << ['1', '3', '5']
  out << ['3', '5', '7']
  out << ['2', '4', '6']
  return out
end
def makeSample2
  out = MyMatrix.new()
  out.addHeaders(['a', 'b', 'c'])
  out << ['4', '5', '8']
  out << ['', '3', '5']
  out << ['3', '5', '7']
  out << ['4', '6', '8']
  out << ['2', '4', '6']
  return out
end
def makeEmptySample
  out = MyMatrix.new()
  out.addHeaders(['a', 'b', 'c'])
  out << ['4', '5', '8']
  out << ['', '', '']
  out << ['', '', '']
  out << ['', '', '']
  return out
end
def makeHankakuSample
  out = MyMatrix.new()
  out.addHeaders(['削除ﾌﾗｸﾞ', 'b', 'c'])
  out << ['4', '5', '8']
  out << ['', '', '']
  out << ['', '', '']
  return out
end

def makecsv
  open('spec/csv.csv', 'w')  do |fo|
    fo.write("a,b,c\r\n")
    fo.write(MyMatrix.tosjis(',奈良,大阪'))
    fo.write("\r\n")
    fo.write(MyMatrix.tosjis('"ダブル""クオーテーション","カン,マ",aaa'))
    fo.write("\r\n")
  end
  mx = MyMatrix.new('spec/csv.csv')
  return mx
end
def makecsv_utf
  open('spec/csv.csv', 'w')  do |fo|
    fo.write("a,b,c\r\n")
    fo.write(',奈良,大阪')
    fo.write("\r\n")
  end
  mx = MyMatrix.new('spec/csv.csv', :encode => 'utf-8')
  return mx
end
def makecsv_norow
  open('spec/csv.csv', 'w')  do |fo|
    fo.write("a,b,c\r\n")
  end
  mx = MyMatrix.new('spec/csv.csv')
  return mx
end


if(__FILE__ == $0)
  p ARGV[0]
  mx = MyMatrix.new(ARGV[0])
  p mx.getHeaders.join("\t")
  mx.each do |row|
    p row.join("\t")
  end
end
