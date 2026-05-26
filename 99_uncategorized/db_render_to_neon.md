## 大まかな手順（260524の場合）
  - [ ] Neon側を準備
  - [ ] [Render Postgres の現状把握(テーブル一覧・件数を控えておく → 後の検証用ベースライン)](#sql復習render-postgres-の現状把握)
  - [ ] Render web service を Starter にアップグレード → Shell 利用可確認
  - [ ] [本番の移行コマンド実行(pg_dump | psql パイプ)](#本番の移行コマンド実行pg_dump--psql-パイプ)
  - [ ] DATABASE_URL 差し替え&動作確認
  - [ ] Render web service を Free にダウングレード
  - [ ] Render db を 削除

## 【SQL復習】Render Postgres の現状把握
今回は3つのSQLを使用
```sql
-- ① 件数取得クエリを「自動生成」するクエリ
SELECT string_agg(
  format('SELECT %L AS table_name, COUNT(*) AS row_count FROM public.%I', tablename, tablename),
  ' UNION ALL '
  ORDER BY tablename
) AS generated_query
FROM pg_tables
WHERE schemaname = 'public';

-- ② ①の出力をコピーして実行(全テーブルの件数が一覧で出る)

-- ③ マイグレーションの最新バージョン確認
SELECT MAX(version) AS latest_migration FROM schema_migrations;
```

### ① の分解 : SQL を使って SQL を書かせる
#### `FROM pg_tables WHERE schemaname = 'public'`
`pg_tables` は PostgreSQL が持つシステムカタログ(DB自身のメタ情報)の一つで、存在するテーブルの一覧が入っています。schemaname = 'public' で絞ると、Rails が作るアプリ用テーブル(users, words, schema_migrations 等)だけが取れて、Postgres 内部の管理用テーブルは除外されます。つまりこの部分で「public スキーマのテーブルが1行ずつ」並んだ状態になります。
#### `format('...%L...%I...', tablename, tablename)`
`format` は他言語の `sprintf` に近い、文字列を組み立てる関数です。プレースホルダが2種類あるのが肝:

`%L` → 値を 文字列リテラルとして埋め込む(自動でクオート付き)。users → 'users'
`%I` → 名前を **識別子(テーブル名・カラム名)**として埋め込む(必要なら安全にクオート)。users → users

同じ `tablename` を2回渡しているのに `%L` と `%I` で使い分けているのがポイントで、役割が違うからです:

```sql
SELECT 'users' AS table_name, COUNT(*) AS row_count FROM public.users
       └─ %L(ラベル用の値)              └─ %I(FROMに置く実テーブル名)
```

ここを取り違えて、FROM 側に `%L` を使うと `FROM public.'users'` という不正な SQL になって壊れます。「値なら `%L`、名前なら `%I`」と覚えておくと、動的 SQL を書くとき事故りません。  
  

#### `string_agg(... , ' UNION ALL ' ORDER BY tablename)`
`string_agg` は、複数行の文字列を1本につなげる集約関数です。第2引数が区切り文字。ここでは各テーブル分の format() の結果を UNION ALL でつなぎ、ORDER BY tablename で並び順を揃えています。  
※ `UNION ALL` → 結果を縦積みする
(重複を消さない分 UNION より速い)

### ② 生成されたクエリを実行
①が吐いた文字列をそのまま実行すると、各テーブルの件数が1行ずつ並んで返ります。  
`UNION ALL` は複数の SELECT 結果を縦に積み重ねる演算子です(`UNION` との違いは、`ALL` は重複行を消さない=速い。件数確認では重複を消す必要が無いので `ALL`)。

### ③ schema_migrations の最新バージョン
`schema_migrations` は Rails がマイグレーションの適用状況を記録するテーブルで、1行が1つのマイグレーション(タイムスタンプ)です。`MAX(version)` でその最新を取れば、移行元と移行先でスキーマの進み具合が一致しているかを一発で照合できます。件数だけでなくこれも見ることで、「テーブル構造もズレなく移った」と確認できるわけです。

### 復習ポイント
- `pg_tables` 等のシステムカタログを使うと、DB の構造そのものを SQL で問い合わせられる
- `format()` の `%L(値)` と `%I(名前)` の使い分けが動的 SQL の事故防止の肝
- `string_agg(..., 区切り ORDER BY ...)` で複数行を1本の文字列に集約 → 「SQL を生成する SQL」が書ける
- `UNION ALL` は結果を縦積み(重複を消さない分 `UNION` より速い)
-  検証は「件数(COUNT) + schema_migrations の最新版」の両面で見るとスキーマもデータも担保できる
  
## 本番の移行コマンド実行(pg_dump | psql パイプ)

```bash
# 前さばき①: 移行元(Render)の接続文字列が入っているか
[ -n "$DATABASE_URL" ] && echo "DATABASE_URL: OK" || echo "DATABASE_URL: 未設定"

# 前さばき②: 移行先(Neon)の接続文字列を変数に入れる
read -rs NEON_DIRECT_URL

# 本体: 移行実行
pg_dump --no-owner --no-privileges "$DATABASE_URL" | psql "$NEON_DIRECT_URL"
```

### 本体: `pg_dump ... | psql ...`
やっていることを一言でいうと `「Render の DB を SQL に変換しながら、その場で Neon に流し込む」`。要素を分解します。  
  
#### `pg_dump`
指定した DB に接続して、その中身を再現するための SQL スクリプトを吐き出すツールです。テーブル定義(CREATE TABLE)、インデックス、シーケンス、制約といった構造と、各テーブルのデータの両方を出力します。デフォルトでは、その SQL を標準出力(画面/パイプ)に流します。

#### `--no-owner`
通常 pg_dump は `ALTER TABLE ... OWNER TO 元のロール名` という所有者設定の文も出力します。  `--no-owner` はこれを省略する指定。省略すると、復元時のオブジェクト所有者は「接続して復元した人(= Neon のロール)」になります。  
→ なぜ必要か: Render 側のロール名は Neon に存在しないので、OWNER TO を含めると「そんなロール無い」エラーになる。だから省いた。

#### `--no-privileges(別名 --no-acl)`
こちらは `GRANT`/`REVOKE`(権限付与・剥奪)の文を省略する指定。理由は `--no-owner` と同じで、存在しないロールへの権限文がエラーになるのを防ぐため。  
→ 2つ合わせて「構造とデータだけ移して、移行元固有の所有者・権限の足場は持ち込まない」という意味になります。別の管理サービスへ移るときの定石です。

#### `"$DATABASE_URL"`
pg_dump の引数 = 読み込み元(Render Postgres)。シェルが実行前に `$DATABASE_URL` を実際の接続文字列に展開します。ダブルクオートは URL 内の特殊文字を守るため。

#### `|(パイプ)`
左の `pg_dump` の標準出力(SQL の流れ)を、右の psql の標準入力に直結する演算子。ここがファイルを作らないカラクリで、データは「Render → pg_dump → パイプ(メモリ上)→ psql → Neon」と流れ、途中でディスクに落ちません。漏洩リスクの温床が生まれないのは、この` | `のおかげ。

#### `psql "$NEON_DIRECT_URL"`
psql は Postgres のコマンドライン接続ツール。標準入力で SQL を渡されると、対話入力の代わりにそれを順に実行します。ここでは Neon に接続して、流れてきた `CREATE TABLE` や `COPY` を実行 = Neon 上に構造とデータを再現します。

### 実行中に流れたログの意味
- `SET` … pg_dump が復元を安定させるために冒頭に置くセッション設定。psql がその実行を1個ずつ報告
- `CREATE TABLE` / `CREATE INDEX` / `ALTER TABLE` … 構造の構築
- `COPY 123` … そのテーブルに 123 行が入った合図。pg_dump はデータ投入に `COPY`(一括ロード)を使うので、`INSERT` を1行ずつより圧倒的に速い
これらは全部「その文が成功したよ」という psql の報告。`ERROR` が混ざらなければ順調、という見方でした

### なぜ direct(unpooled)URL を使ったか
ここは地味だけど大事な判断でした。本番アプリには pooled(PgBouncer 経由)を使うのに、移行では direct を使ったのは、pooled の「トランザクションプーリング」がセッション単位の状態や大きなトランザクションを前提とした処理(まさに復元作業)で詰まることがあるから。直結の direct なら pg_dump の出力が要求する操作を素直に通せます。
→ 移行は direct、本番運用は pooled。同じ DB でも、用途で接続の入り口を使い分ける、という整理です。

### 前さばきのコマンドたち（軽く整理）
#### `[ -n "$DATABASE_URL" ] && echo "OK" || echo "未設定"`
`[ -n "$VAR" ]` は「文字列が空でないか」のテスト(-n = non-empty)。`A && B || C` はシェルの短絡評価で「A が成功なら B、失敗なら C」。値そのものを画面に出さずに「セットされているか」だけ確認できる。

#### `read -rs NEON_DIRECT_URL`
入力1行を変数 `NEON_DIRECT_URL` に格納。  
- `-r`=バックスラッシュをそのまま扱う
- `-s`=画面に表示しない。  

`read` の入力はコマンド履歴に残らないので、接続文字列が `history` に漏れない。

### 復習ポイント
- `pg_dump` は「DB を再現する SQL を吐く」、`psql` は「SQL を実行する」。`|` で繋ぐとファイルを介さず移行できる
- `--no-owner` / `--no-privileges` は「移行元のロール依存(所有者・権限)を持ち込まない」ための定石。別プロバイダへの移行で効く
- データ投入は `COPY`(一括)なので速い。`COPY N` はその行数の確認になる
- 接続は 移行=direct / 本番=pooled と使い分ける
- 値を画面・履歴に出さずに状態を確かめる小技: `[ -n "$VAR" ]`(存在)、`${#VAR}`(文字数)、``${VAR: -N}`(末尾)