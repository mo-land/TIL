
### railsconsoleで改行しながら入力する方法
記述するコードをbeginとendで囲う。

# 逆引きネタ帳らしきもの
## テーブル1つ
#### 例：テーブル（生徒）をカラム（出席番号）の値（3）で絞って取得
`テーブル.where(カラム: 絞りたい値)`

#### 例：テーブル（生徒）をカラム（苗字）の値（田中）で絞ったときに一番若いIDのレコードを取得
`テーブル.find_by(カラム: 絞りたい値)`

#### 例：テーブル（生徒）の指定したカラム（id、フルネーム）だけ取得　※whereなどで指定しないとたくさん出るので注意
`テーブル.select(:カラム, :カラム)`

#### 例：テーブル（生徒の年齢）で、カラム（生年月日）が`【2005年中】`の者だけを取得
`テーブル.where(カラム: Time.new(2005).beginning_of_year..Time.new(2005).end_of_year)`

#### 例：テーブル（生徒の年齢）で、カラム（入学年月日）が`【空欄】`の者だけを取得
`テーブル.where(カラム: nil)`

## テーブル複数
#### 例：テーブル2（出席者）で、テーブル1（生徒）で指定した情報（カラム（苗字）の値＝田中）と一致するレコードの数を取得
`テーブル1.find_by(カラム名: 絞りたい値).テーブル2（複数形）.size`

#### 例：テーブル2（出席者）にテーブル1（生徒）の情報を結合し、テーブル1（生徒）のカラム（苗字）の値が田中であるレコードの数を取得
`テーブル2.joins(:テーブル1).where(テーブル1: { カラム: 絞りたい値 }).size`

#### 例：テーブル1 （生徒）の情報を取得。条件は、テーブル3（生徒の年齢）のカラム（生年月日）で値（2005年中）となっていること。
対応するカラム有：`テーブル1⇔テーブル2`、`テーブル2⇔テーブル3`  
`テーブル1.joins(テーブル2（複数形）: :テーブル3（複数形）).where({ テーブル3: カラム: 値 })`  

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