## 目次
- [目次](#目次)
- [📝配列](#配列)
- [🔤文字列操作](#文字列操作)


## 📝配列
### 📝`map()` vs `list(map())` の違い
#### 競プロでの使い分け

```python
# forで一度回すだけ → mapで十分
for n in map(int, input().split()):
    print(n)

# インデックス参照や複数回使う → list化
nums = list(map(int, input().split()))
print(nums[0] + nums[-1])
```

> **迷ったら `list(map(...))` を使えば間違いない。**

<details><summary>その他説明</summary>

#### ポイント：遅延評価 vs 即時評価

| | `map(int, ...)` | `list(map(int, ...))` |
||||
| 返る型 | mapオブジェクト（イテレータ） | list |
| 評価タイミング | 要素を取り出す瞬間 | 呼び出し時に全展開 |
| インデックスアクセス `[0]` | ❌ | ✅ |
| `len()` | ❌ | ✅ |
| 複数回ループ | ❌（使い切り） | ✅ |

#### コード例

```python
# mapオブジェクトのまま → インデックス不可
m = map(int, "1 2 3".split())
m[0]    # ❌ TypeError
len(m)  # ❌ TypeError

# list化 → 普通のリストとして使える
nums = list(map(int, "1 2 3".split()))
nums[0]    # ✅ 1
len(nums)  # ✅ 3
```

</details>


### 📝`range()` と ループ内 `input()` の基本

#### range(n) の基本

```python
range(3)        # 0, 1, 2       ← 0始まり、n は含まない
range(1, 4)     # 1, 2, 3
range(0, 6, 2)  # 0, 2, 4       ← ステップ指定
```

#### 「n回、毎回1行入力を受け取る」パターン

```python
n = int(input())    # まず「何回入力するか」を受け取る

for i in range(n):  # n回ループ
    m = int(input())    # 毎ループで1行受け取って整数に変換
    print(m)
```

標準入力がこういう形式のときに対応：

```
3     ← n（ループ回数）
10    ← 1回目の m
200   ← 2回目の m
30    ← 3回目の m
```

<details><summary>その他説明</summary>

#### ループ変数を使わないとき

`i` を使わない場合は `_` と書くのが慣習。

```python
for _ in range(n):  # i を使わないことを明示
    m = int(input())
    print(m)
```

> **競プロでは `for _ in range(n):` のパターンが頻出。**

</details>

### 📝`while` 文の基本
 
#### 基本構文
 
```python
count = 1
while count <= 3:   # 条件がTrue の間ループ
    print(count)
    count += 1      # ← 忘れると無限ループ！
# 1, 2, 3
```
 
#### for 文との使い分け
 
| | `for` | `while` |
|---|---|---|
| 向いているケース | 繰り返し回数が事前に分かる | 条件によって回数が変わる |
| 例 | リストの全要素を処理 | 特定の条件を満たすまで処理 |
 
#### 無限ループ + `break`（意図的な無限ループ）
 
```python
count = 0
while True:         # 常にTrue → 無限ループ
    count += 1
    if count > 3:
        break       # ← ここで抜ける
    print(count)
# 1, 2, 3
```
 
> **`while True:` はbreak を書き忘れるとプログラムが止まらなくなる。終了条件を先に設計しておく。**
 
#### `break` vs `continue`
 
```python
count = 0
while count < 5:
    count += 1
    if count == 3:
        continue    # 3だけスキップ、ループは続く
    print(count)
# 1, 2, 4, 5
 
# ※ continueより前でカウンタを更新しないと無限ループになる
```
 
| | 動作 |
|---|---|
| `break` | ループを即座に終了 |
| `continue` | 今回の処理だけスキップして次のループへ |
 
#### 強制終了（無限ループに陥ったとき）
 
```
Ctrl + C（Windows / Linux）
Cmd  + C（Mac）
```
 
#### デバッグの基本
 
```python
while count > 0:
    print(f"現在のcount: {count}")  # 変数の変化を追跡
    count -= 1
```

## 🔤文字列操作
### 🔤文字列の桁揃えフォーマット `"f{m: >N}"`
#### f文字列版（モダンな書き方）

```python
m = 5
print(f"{m: >3}")   # "  5"
print(f"{m:0>3}")   # "005"
```

> **迷ったら f文字列版を使うのが今風。競プロでも読みやすい。**

<details><summary>ちょっとレガシーな書き方‥？</summary>

### 🔤文字列の桁揃えフォーマット `"{: >N}".format()`
#### 書式の構造

```
"{: >3}".format(m)
   ↑ ↑ ↑
   │ │ └── 幅（最低N文字分確保）
   │ └──── 寄せ方（> 右寄せ）
   └────── 埋める文字（省略 = スペース）
```

#### 動作イメージ

```python
print("{: >3}".format(1))    # "  1"  スペース2つ + 1
print("{: >3}".format(12))   # " 12"  スペース1つ + 12
print("{: >3}".format(123))  # "123"  ちょうど3文字
print("{: >3}".format(1234)) # "1234" 超えても切り捨てなし
```

#### 寄せ方・埋め文字のバリエーション

```python
"{: >3}".format(5)   # "  5"  右寄せ（数値によく使う）
"{: <3}".format(5)   # "5  "  左寄せ
"{: ^3}".format(5)   # " 5 "  中央寄せ
"{:0>3}".format(5)   # "005"  0埋め（スペース → 0に変更）
```

</details>

### 動的な幅指定フォーマット `f"{n:0>{m}}"`
#### f文字列版（メイン）
 
```python
n, m = 321, 5
 
print(f"{n: >{m}}")   # "  321"  スペース埋め・右寄せ
print(f"{n:0>{m}}")   # "00321"  0埋め・右寄せ
print(f"{n: <{m}}")   # "321  "  スペース埋め・左寄せ
print(f"{n: ^{m}}")   # " 321 "  スペース埋め・中央寄せ
```
 
#### 入力値から幅を動的に決めるパターン（競プロ頻出）
 
```python
values = input().split()   # 例: "321 5"
n = int(values[0])         # 321（表示する値）
m = int(values[1])         # 5（幅）
 
print(f"{n: >{m}}")        # "  321"
print(f"{n:0>{m}}")        # "00321"
```
 
> **`{m}` の部分が「幅を変数で渡す」構文のキモ。固定幅なら数字、動的なら変数名を入れる。**


<details><summary>【.format()版】※参考</summary>

 
#### 構造の整理
 
```
"{: >{}}".format(n, m)
   ↑ ↑ ↑↑
   │ │ │└── 2つ目の {} → m が入る（幅の指定）
   │ │ └─── > 右寄せ
   │ └───── 埋める文字（スペース）
   └─────── 1つ目の {} → n が入る（表示する値）
```
 
 

</details>

<!-- 疑問が増えたらここに追記 -->

<details><summary>その他説明</summary>
説明
</details>