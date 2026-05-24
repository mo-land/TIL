## 大まかな手順（260524の場合）
  - [ ] Neon側を準備
  - [ ] Render Postgres の現状把握(テーブル一覧・件数を控えておく → 後の検証用ベースライン)
  - [ ] Render web service を Starter にアップグレード → Shell 利用可確認
  - [ ] 本番の移行コマンド実行(pg_dump | psql パイプ)
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