
# railsconsoleで改行しながら入力する方法
記述するコードをbeginとendで囲う。

# 逆引きネタ帳らしきもの
## 単数モデル
##### 例：モデル（生徒）をカラム（出席番号）の値（3）で絞って取得
`モデル.where(カラム: 絞りたい値)`
##### 例：モデル（生徒）をカラム（苗字）の値（田中）で絞ったときに一番若いIDのレコードを取得
`モデル.find_by(カラム: 絞りたい値)`
##### 例：モデル（生徒）の指定したカラム（id、フルネーム）だけ取得　※whereなどで指定しないとたくさん出るので注意
`モデル.select(:カラム, :カラム)`
##### 例：モデル（生徒の年齢）で、カラム（生年月日）が`【2005年中】`の者だけを取得
`モデル.where(カラム: Time.new(2005).beginning_of_year..Time.new(2005).end_of_year)`
##### 例：モデル（生徒の年齢）で、カラム（入学年月日）が`【空欄】`の者だけを取得
`モデル.where(カラム: nil)`
##### 例：モデル（学費）で、まとめたいカラム（月）ごとに合計したいカラム（預かり金額）の合計を取得
`モデル.group(:まとめたいカラム).sum("合計したいカラム")`
##### 例：モデル（学費）で、まとめたいカラム（月、取得したいカラムも同じ）ごとに 合計したいカラム（預かり金額）の合計で`【多い順に5件】`を取得
`モデル.select("取得したいカラム（複数可能）, sum(合計したいカラム) as 合計行に付けるカラム名").group(:まとめたいカラム).limit(5).order(revenue: :desc)`  
[【Rails】ActiveRecordで合計(sum)した列に列名(AS句)をつけたい【GROUP BY】](https://qiita.com/Orangina1050/items/93dd407ac54f855d9d7d)
##### 例：モデル（学費）で、まとめたいカラム（月、取得したいカラムも同じ）ごとに カウント行カラム（徴収済）の`【カウントが60以上の多い順】`を取得
`モデル.select("取得したいカラム（複数可能）, count(*) as カウント行に付けるカラム名")`  
`.group(:まとめたいカラム).having("カウント行に付けるカラム名 >= 60").order("カウント行に付けるカラム名 desc")`
## 複数モデル
##### 例：モデル2（出席者）で、モデル1（生徒）で指定した情報（カラム（苗字）の値＝田中）と一致するレコードの数を取得
`モデル1.find_by(カラム名: 絞りたい値).モデル2（複数形）.size`
##### 例：モデル2（出席者）にモデル1（生徒）の情報を結合し、モデル1（生徒）のカラム（苗字）の値が田中であるレコードの数を取得
`モデル2.joins(:モデル1).where(モデル1: { カラム: 絞りたい値 }).size`
##### 例：モデル1 （生徒）の情報を取得。条件は、モデル3（生徒の年齢）のカラム（生年月日）で値（2005年中）となっていること。
対応するカラム有：`モデル1⇔モデル2`、`モデル2⇔モデル3` 　**※モデル2は中間テーブルではない**  
`モデル1.joins(モデル2（複数形）: :モデル3（複数形）).where({ モデル3: カラム: 値 })`
##### 例：モデル1 （生徒）の情報を取得。条件は、モデル3（生徒の年齢）のカラム（生年月日）で値（2005年中）となっていること。
対応するカラム有：`モデル1⇔モデル2`、`モデル2⇔モデル3` 　**※モデル2は中間テーブルである**  
`モデル1.joins(:モデル3（複数形）).where({ モデル3: カラム: 値 })`

## モデル数によるselect、groupの書き方の違い

| ケース | selectの書き方 | groupの書き方 | 備考 |
| --- | --- | --- | --- |
| 単一モデル | `Model.select(:column1, :column2)` | `Model.group(:column)` | テーブル名の指定不要 |
| 複数モデル（joins使用） | `Model.joins(...).select("table1.column, table2.column")` | `Model.joins(...).group("table.column")` | 明示的に `table.column` 指定が必要 |
| 複数モデル（includes使用 + SQL書く場合） | 同上（includesでもSQLを書くなら明示） | 同上 | `includes`は通常Eager LoadingなのでSQLで指定しないこともある |

# 時間関連の書き方
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