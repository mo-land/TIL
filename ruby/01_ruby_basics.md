## 未分類


### 後置if
`式 if 式`  
右辺の条件が成立する時に、左辺の式を評価してその結果を返します。  
条件が成立しなければ nil を返します。  

### 絶対値に変換
```rb
p -3.abs
#=> 3
```

### 小数点以下N桁で切り捨て
floorメソッドを使う！[参考](https://qiita.com/tomokichi_ruby/items/e94a7336585f72b8a594#%E5%B0%8F%E6%95%B0%E7%82%B9%E4%BB%A5%E4%B8%8Bn%E6%A1%81%E3%81%A7%E5%88%87%E3%82%8A%E6%8D%A8%E3%81%A6)  
```rb
500.3333.floor
# 出力結果 ==> 500
```

### 範囲式もeachと一緒に使える
こちらもCheck!→ [**`範囲.each ～ 配列に要素を追加`** を **`範囲.to_a`** でシンプルに🌟](./01_ruby_basics.md#範囲each--配列に要素を追加-を-範囲to_a-でシンプルに)
```rb
(1..3).each { |i| puts "..付き: #{i}" }
(1...3).each { |i| puts "...付き: #{i}" }

# 出力
..付き: 1
..付き: 2
..付き: 3
...付き: 1
...付き: 2
```

## 正規表現
### `正規表現【[あいう]】＝「あ」と「い」と「う」にマッチするものを選択`
```rb
name = 'ポプテピピック'

# gsub で「パピプペポ」を一括削除
puts name.gsub(/[パピプペポ]/, '') # => テック
```

### `+`= 1回以上の繰り返し
```rb
file_name = "wwwwwwwwww草生やしすぎwに注意ww"
puts file_name.gsub(/w+/, '🫶')　# w（1文字or連続）を🫶1つに変換する
puts file_name.gsub(/ww+/, '🫶') # w（連続）を🫶1つに変換する
puts file_name.gsub(/w+/, 'w')　 # ww...（イラッとする草）を w（広い心で見れば許せる草）に変換する

# 出力
🫶草生やしすぎ🫶に注意🫶
🫶草生やしすぎwに注意🫶
w草生やしすぎwに注意w
```

## 配列
### Set+include?で処理を高速化！
参考：[【Ruby on Rails】Set#include?がなぜ速いのかを理解する](https://qiita.com/an_sony/items/708c47d073ad709431d6)
#### 配列での検索 - O(n)
```rb
array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
array.include?(7)  # どう動作するか？

# 内部動作:
# 1回目: 1 == 7? → No
# 2回目: 2 == 7? → No
# 3回目: 3 == 7? → No
# ...
# 7回目: 7 == 7? → Yes! 見つかった!

# 最悪の場合、全要素をチェック
```

#### Set での検索 - O(1)
`require 'set'`:「Ruby標準ライブラリのSetクラスを使えるようにして」という命令
```rb
require 'set'
set = Set.new([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
set.include?(7)  # どう動作するか？

# 内部動作:
# 1. 7のハッシュ値を計算 → 即座に位置を特定
# 2. その位置を1回だけチェック → 見つかった!

# データ量に関係なく、ほぼ1回で見つかる
```

### each + << → map メソッドでシンプルに
```rb
# each + <<
numbers = [1, 2, 3, 4, 5]
squared_each = []  # 結果を入れる空配列を用意

numbers.each do |n|
  squared_each << n * 2
end

puts "each結果: #{squared_each.inspect}"  # => [2, 4, 6, 8, 10]


# map
numbers = [1, 2, 3, 4, 5]
squared_map = numbers.map { |n| n * 2 }

puts "map結果: #{squared_map.inspect}"    # => [2, 4, 6, 8, 10]
```
### `each + if` +` <<` → `select`メソッド でシンプルに
```rb
# リファクタリング前：each + if + << の組み合わせ
numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

# 偶数だけを新しい配列に集める（古い書き方）
even_numbers = []
numbers.each do |number|
  if number.even?
    even_numbers << number
  end
end
```
```rb
# リファクタリング後：selectメソッドを使用
numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

# 偶数だけを新しい配列に集める（推奨の書き方）
even_numbers = numbers.select { |number| number.even? }
puts "偶数: #{even_numbers}"
# => [2, 4, 6, 8, 10]
```
### `chars` 
[参考](https://docs.ruby-lang.org/ja/latest/method/String/i/chars.html)  
文字列の各文字を文字列の配列で返します。
```rb
"hello世界".chars # => ["h", "e", "l", "l", "o", "世", "界"]
```
### `any? メソッド`
[参考](https://zenn.dev/take_tech/articles/d2a4e7d17b6180)  
ブロックが与えられた場合、そのブロックの条件を満たす要素が少なくとも一つ配列内に存在するかどうかを確認します。  
ブロックが与えられない場合は、配列に少なくとも一つの要素が存在するかどうかをチェックします。  
```rb
numbers = [1, 2, 3, 4]

numbers.any? { |n| n > 3 } # => true
numbers.any? { |n| n > 4 } # => false
numbers.any? # => true
[].any? # => false
```

### `a|b` → 配列をマージする
参考：[[Ruby]配列をマージ・結合する](https://qiita.com/kenbu/items/68e230ae6e1f7b80c778)  
重複は排除する  
※` a + b`や`a.concat(b)`は、重複排除されない
```rb
a = ["札幌", "函館", "旭川"]
b = ["仙台", "金沢", "札幌"]
p a|b

# 出力
["札幌", "函館", "旭川", "仙台", "金沢"]
```

### lastメソッド
参考：[Ruby 3.4 リファレンスマニュアル last](https://docs.ruby-lang.org/ja/latest/method/Array/i/last.html)  
配列の末尾の要素を返します。配列が空のときは nil を返します。
```rb
p [0, 1, 2].last   #=> 2
p [].last          #=> nil
```
### `a & b` → 配列a, bで、重複する要素のみを取り出す
参考：[複数の配列を比較し重複する値を取る](https://qiita.com/tomomomo1217/items/c8a2db5bbcdccdb20690)

### 範囲.each ～ 配列に要素を追加`** を **`範囲.to_a`** でシンプルに🌟
```rb
# 改善前
numbers = []
(1..5).each do |i|
    numbers << i
end

# 改善後
numbers = (1..5).to_a

# 両方とも、numbers = [1, 2, 3, 4, 5]となる
```

### include?メソッド
指定した要素が、配列中に含まれているかを判定。[参考](https://qiita.com/mr0216/items/e3037408d0676e53481c)  
```rb
animals = ["お犬さま", "ゴリラ殿", "ヌコ様", "亀たそ"]
result = animals.include?("亀たそ") ? "Yes" : "No"
puts result

# 出力
Yes
```
※三項演算子にも慣れたい

### 同じメソッドでも、色んな使い方があるなぁと思った話
#### ①reverseメソッドは、前にsortがあるかどうかで出力が変わる
```rb
p [5,4,1,2,3].reverse #→ [3, 2, 1, 4, 5] （元の並び順を逆に出力）
p [5,4,1,2,3].sort.reverse #→ [5, 4, 3, 2, 1] （数字の降順：sortで昇順ソートした後、reverseで要素の順序を逆転するため、結果的に降順ソートになる。）
```
#### ②countメソッドも、以下のように書き方によって意味合いが変わる。
```rb
p  [1, 2, 4, 2.0].count #→ 4（配列に含まれる要素の数を数える）
p  [1, 2, 4, 2.0].count(2) #→ 2（配列に含まれる2の数を数える。2.0（浮動小数点数）は異なる値として扱う）
p  [1, 2, 4, 2.0].count{|x|x%2==0} #→ 3（配列に含まれる、2で割り切れる要素の数を数える）
```
### delete_atメソッド
配列から、引数に指定したインデックス番号の要素を削除して取り出す。  
  
▼例（[Ruby 3.4 リファレンスマニュアル ](https://docs.ruby-lang.org/ja/latest/method/Array/i/delete_at.html)から引用）
```rb
array = [0, 1, 2, 3, 4]
array.delete_at 2
p array             #=> [0, 1, 3, 4]
```
### insertメソッド
配列の任意の場所に要素を挿入する  
▼例（[Ruby 3.4 リファレンスマニュアル ](https://docs.ruby-lang.org/ja/latest/method/String/i/insert.html)から引用）
```rb
str = "foobaz"
str.insert(3, "bar")
p str   # => "foobarbaz"
```

### 📝mapメソッド
配列の各要素を変換した配列を作る

```rb
result = [1, 2, 3].map { |x|   # ←xに1 2 3が順に代入される
    x  * 2   # ←変換処理
}
#=> [2, 4, 6]
```

## ハッシュ
### キーと値の組を追加・削除する
- ハッシュへのキーと値の追加は `ハッシュ[キー] = 値`
- ハッシュは同じキーを複数持てない
- ハッシュから存在しないキーを取得すると、nil を得る
- `ハッシュ.default= キーがないときの値`で、ハッシュから存在しないキーを取得しようとした時の値を設定することもできる
- ハッシュ1とハッシュ2をまとめるときは、`ハッシュ1.merge(ハッシュ2)`
- ハッシュからの削除は、`ハッシュ.delete(キー)`

### ハッシュの繰り返し処理
```rb
# eachメソッド
ハッシュ.each do |キーの変数, 値の変数|
　繰り返し実行する処理
end

# each_keyメソッド
ハッシュ.each_key do |キーの変数|
  繰り返し実行する処理
end

# 値だけを繰り返しするeach_valueメソッドもある
```
