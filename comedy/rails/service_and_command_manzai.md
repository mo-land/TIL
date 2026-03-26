## 漫才「サービスさんとコマンドさん」

**登場人物**

* ボケ：Rails初学者
* ツッコミ：ちょっと設計にうるさい人

---

**ボケ**
どうも〜！今日はRailsのディレクトリ整理をしてたんですけどね！

**ツッコミ**
ほう、えらいな。

**ボケ**
`app/services/` と `app/commands/` があったんですよ。

**ツッコミ**
ある時あるな。

**ボケ**
で、どっちも「何かやる場所」に見えて、もう全部 `app/ore/` に入れたろか思いまして。

**ツッコミ**
やめなさい。治安が終わる。

---

**ボケ**
でも実際、似てません？
サービスもコマンドも、結局「処理まとめる箱」やないですか。

**ツッコミ**
その雑さで片付けると、後で自分に刺されるやつや。

**ボケ**
未来の自分に？

**ツッコミ**
うん。しかも急所。

---

**ボケ**
じゃあ何が違うんです？

**ツッコミ**
ざっくり言うと、
**Service は「何かの機能・役割」**、
**Command は「これを実行せよ」という命令単位** や。

**ボケ**
はい、わかりません。

**ツッコミ**
はやいな。理解を諦める速度がCDNや。

---

### 1. Service は「役割」で切る

**ツッコミ**
たとえばやな、
ユーザー登録時にプロフィール初期化したり、招待特典つけたり、通知送ったりする処理があるとするやろ？

**ボケ**
ありますあります。盛りだくさん会員登録セット。

**ツッコミ**
この中で、
「通知を送る」
「OGP画像を作る」
「検索条件を組み立てる」
みたいに、**ある責務を持った再利用しやすい処理**は Service に置くイメージや。

**ボケ**
なるほど。
「何を担当してるか」で名前がつく感じか。

**ツッコミ**
そう。
たとえば

```ruby
NotificationSender.call(user, message)
ProfileInitializer.call(user)
SearchQueryBuilder.call(params)
```

みたいな。

**ボケ**
たしかに“役職名”っぽいですね。
送信係、初期化係、組み立て係。

**ツッコミ**
そういうことや。
**Service は「この人は何屋さんか」が見えやすい。**

---

### 2. Command は「一回の命令」で切る

**ボケ**
じゃあ Command は？

**ツッコミ**
Command は、
**「ユーザー登録を実行する」**
**「注文を確定する」**
**「請求を発行する」**
みたいな、**1回の操作・ユースケース**に寄る。

**ボケ**
役職じゃなくて、依頼書？

**ツッコミ**
かなり近い。
「〇〇してください」っていう**アクション単位**や。

```ruby
RegisterUser.call(params)
CompleteOrder.call(order:)
IssueInvoice.call(order:)
```

**ボケ**
おお、たしかに Service より「実行イベント」感ある。

**ツッコミ**
そう。
Command は、**入力を受けて、その命令を完遂する**主役になりやすい。

---

### 3. 例えるなら

**ボケ**
まだちょっとフワつくなあ。

**ツッコミ**
じゃあ飲食店で例えるで。

**ボケ**
来た来た、たとえ話。

**ツッコミ**
Service は、

* 仕込み担当
* 盛り付け担当
* 会計計算担当

みたいな**役割ベース**や。

**ボケ**
うんうん。

**ツッコミ**
Command は、

* 「ラーメン1杯作って出して」
* 「会計を締めて」
* 「本日の売上を確定して」

みたいな**指示ベース**や。

**ボケ**
あー！
Service は厨房の専門係、
Command は店長の「これやっといて」か！

**ツッコミ**
そうそう。
Command の中で必要なら複数の Service を呼ぶこともある。

**ボケ**
つまり
**Command が段取り組んで、Service が各自仕事する**
みたいな感じ？

**ツッコミ**
ええ線いってる。

---

### 4. よくある構成

**ボケ**
じゃあ、ユーザー登録ならこんな感じ？

```ruby
class RegisterUser
  def self.call(params)
    user = User.create!(params)
    ProfileInitializer.call(user)
    WelcomeNotificationSender.call(user)
    user
  end
end
```

**ツッコミ**
そう、それはかなり Command っぽい。

**ボケ**
で、`ProfileInitializer` と `WelcomeNotificationSender` は Service。

**ツッコミ**
うむ。
**Command はユースケース全体を前に進める係**、
**Service はその中の部品・役割**。

**ボケ**
おお、急に景色が見えてきた。

---

### 5. でも Service だけでよくない？

**ボケ**
でもさ、全部 Service にしても動くやん。

**ツッコミ**
動く。めちゃくちゃ動く。

**ボケ**
じゃあええやん。

**ツッコミ**
その結果、こうなる。

```ruby
UserRegistrationService.call(params)
OrderCompletionService.call(order)
InvoiceIssueService.call(order)
PasswordResetService.call(user)
```

**ボケ**
うん、全部 Service。

**ツッコミ**
さらにこうなる。

```ruby
EmailVerificationService.call(user)
CartCleanupService.call(user)
MembershipUpgradeService.call(user)
```

**ボケ**
全部 Service。

**ツッコミ**
で、半年後。

**ボケ**
はい。

**ツッコミ**
「これ、“役割”のサービスなんか、“命令”のサービスなんか、どっちや……？」
ってなる。

**ボケ**
名前だけでは思想が見えへん！

**ツッコミ**
そう。
Service は便利すぎて、**何でも入る万能棚**になりやすい。

**ボケ**
押し入れの奥から昔のロジック出てくるやつや。

---

### 6. Command を分けるメリット

**ツッコミ**
だから Command を分けると、
「これは1つのユースケースを実行するクラスなんやな」
って読み手に伝わりやすい。

**ボケ**
設計の意図がファイルパスに出る、と。

**ツッコミ**
そうや。
`app/commands/register_user.rb` ってあったら、
「あ、ユーザー登録そのもの担当なんやな」
ってわかる。

**ボケ**
`app/services/profile_initializer.rb` は、
「あ、プロフィール初期化の専任担当なんやな」
ってわかる。

**ツッコミ**
そう。
読み手に優しい。

**ボケ**
未来の自分にも？

**ツッコミ**
未来の自分は今いちばん守るべき人材や。

---

### 7. じゃあ絶対こう分けるべき？

**ボケ**
じゃあ Rails では絶対、
Command と Service を分けなあかんのですか？

**ツッコミ**
いや、絶対ではない。

**ボケ**
あ、そうなんだ。

**ツッコミ**
アプリの規模やチームの文化による。
小さめのアプリなら `app/services/` だけで十分回ることも多い。

**ボケ**
じゃあ `app/commands/` 作った瞬間に上級者ってわけでもない？

**ツッコミ**
それは違う。
ディレクトリ増やしただけで設計が良くなるなら、みんな幸せや。

**ボケ**
つらい現実。

---

### 8. 判断の目安

**ツッコミ**
こう考えるとわかりやすい。

* **再利用される役割・機能**なら Service
* **1回の業務命令・操作の完遂**なら Command

**ボケ**
たとえば
「メール送信」は Service、
「会員登録を実行」は Command。

**ツッコミ**
そう。
「検索条件を組み立てる」は Service、
「レポートを作成して送る」は Command。

**ボケ**
「画像をリサイズする」は Service、
「商品画像を公開する」は Command。

**ツッコミ**
うまい。だいぶわかってきたな。

---

### 9. ボケの暴走

**ボケ**
じゃあ僕も作ります！

**ツッコミ**
おっ。

**ボケ**
`app/commands/send_email.rb`

**ツッコミ**
それ単体なら Service でもよさそうやな。

**ボケ**
`app/services/register_user.rb`

**ツッコミ**
それは Command っぽいな。

**ボケ**
`app/whatever/do_the_thing.rb`

**ツッコミ**
設計から逃げるな。

**ボケ**
`app/ultimate/final_final2_revised.rb`

**ツッコミ**
リネーム履歴がファイル名に出とる。

---

### 10. 着地点

**ボケ**
なるほどなあ。
Service は**処理の専門職**、
Command は**ユースケース実行係**か。

**ツッコミ**
その理解でかなりええ。

**ボケ**
で、Command の中で必要に応じて Service を呼ぶことがある。

**ツッコミ**
そう。
ただし毎回そうしなきゃいけないわけでもなくて、
アプリの複雑さに応じて使い分ける。

**ボケ**
つまり、
「何でも Service に入れても動くけど、
ユースケース単位をはっきり見せたいなら Command を切ると見通しがよくなる」
ってことですね！

**ツッコミ**
今日はようやくちゃんと着地したな。

**ボケ**
はい！ もう迷いません！

**ツッコミ**
ほんまか？

**ボケ**
はい！ 次は `app/interactors/` と `app/use_cases/` と `app/workflows/` の違いを考えます！

**ツッコミ**
寝不足の時に触る話題ちゃうねん！

---

## 配役を一言で置くなら

* **Service**
  「ある役割を担当する、再利用しやすい処理」

* **Command**
  「ある操作・命令を受けて、1つのユースケースを実行する処理」

---

## おまけ：超ざっくり命名例

**Service に置くとしっくり来やすいもの**

```ruby
PriceCalculator
NotificationSender
ProfileInitializer
SearchQueryBuilder
ImageResizer
```

**Command に置くとしっくり来やすいもの**

```ruby
RegisterUser
CompleteOrder
PublishArticle
IssueInvoice
ResetPassword
```

必要なら次は
**「Interactor / UseCase / Service / Command の四者会談コント」**
みたいな感じで、さらにややこしいやつも作れるで。
