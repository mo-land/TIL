## float型の秒数を時:分:秒形式で小数点第2位まで表示するには？
以下のようにヘルパーメソッドを使います。  
Time.at()で秒数をTimeオブジェクトに変換し、.utcでUTCタイムゾーンに設定、.strftime()で希望のフォーマットに整形します。  
```ruby
    <%= Time.at(completion_time_seconds).utc.strftime("%H:%M:%S.%2N") %>
```

## View（erb）における複数行のコメントアウト
ポイントは、‘=‘を行頭に置くこと。余分なスペース禁止。
```rb
<% 
=begin%>
   全部コメントアウト状態になる
<%
=end%>
```

