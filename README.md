# mymatrix

## DESCRIPTION:

mymatrix is a handling library for MS Excel and  csv/tsv text.

## FEATURES/PROBLEMS:
Support filetypes: .xls, .tsv, .csv /
.xlsx is not supported.

## REQUIREMENTS:
Support ruby versions are:
ruby 1.8.7,
ruby 1.9.2 or higher

## INSTALL:
gem install mymatrix
(It's hosted on gemcutter.org)

## HOW TO USE:
read and write file

```ruby
require 'mymatrix'
mx = MyMatrix.new('path/to/xlsfile.xls')
mx.each_with_index do |row, i|
  the_column = 'sample_column_name'

  # print value of the cell.
  p mx.val(row, the_column)

  # write value of the cell
  mx.setValue(row, the_column, i) # write "i" value to the cell

  # text_output(default is tsv:tab separated values)
  mx.to_t('path/to/text.txt')
  # csv_output
  mx.to_csv('path/to/csv.csv')
end
```

## LICENSE:
(The MIT License)

Copyright (c) 2009-2013 zucay

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
