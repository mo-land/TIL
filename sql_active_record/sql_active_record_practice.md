
### railsconsoleで改行しながら入力する方法
記述するコードをbeginとendで囲う。

### Time.new
🔖[Ruby3.4リファレンスマニュアル](https://docs.ruby-lang.org/ja/latest/method/Time/s/new.html)  
Time.new(year, mon = nil, day = nil, hour = nil, min = nil, sec = nil, in: nil)  
 → 引数で指定した地方時の Time オブジェクトを返します。

mon day hour min sec に nil を指定した場合の値は、その引数がとり得る最小の値です。  
zone と in に nil を指定した場合の値は、現在のタイムゾーンに従います。  

```rb
Time.new(2005).beginning_of_year..Time.new(2005).end_of_year
# => 2005-01-01 00:00:00 +0900..2005-12-31 23:59:59.999999999 +0900

p Time.new(2008, 6, 21, 13, 30, 0, "+09:00") 
# => 2008-06-21 13:30:00 +0900
```

### beginning_of_year、end_of_year 
🔖[Railsガイド](https://railsguides.jp/active_support_core_extensions.html#beginning-of-year%E3%80%81end-of-year)  
beginning_of_yearメソッドとend_of_yearメソッドは、その年の「最初の日」と「最後の日」をそれぞれ返します。  
  
```rb
d = Date.new(2010, 5, 9) # => Sun, 09 May 2010
d.beginning_of_year      # => Fri, 01 Jan 2010
d.end_of_year            # => Fri, 31 Dec 2010
```