## 0611_TIL投稿用のファンクションを絶対パス仕様に変更
```
# TIL起動
til() {
  cd 'pwdコマンドで返される絶対パス'
  git pull origin main
  code .
}

# Til_add~push
# 引数にコミットメッセージのコメントを""で囲って記載
til_cmpsh() {
    local commit_message="$1"
    
    # 引数チェック
    if [ -z "$commit_message" ]; then
        echo "使用方法: til_cmpsh <"コミットメッセージ">"
        return 1
    else
        cd 'pwdコマンドで返される絶対パス'
        git add .
        git commit -m "$commit_message"
        git push origin main
    fi
}
```

## 0609_TILコミット用のファンクションにpushコマンドも追加
```
# Til_add~push
# 引数にコミットメッセージのコメントを""で囲って記載
til_cmpsh() {
    local current_dir=$(pwd)
    local commit_message="$1"
    
    # 引数チェック
    if [ -z "$commit_message" ]; then
        echo "使用方法: til_cmpsh <"コミットメッセージ">"
        return 1
    fi
    
    # ディレクトリチェック
    if [ "$current_dir" = "/home/mo/TIL" ]; then
        git add .
        git commit -m "$commit_message"
        git push origin main
    else
        echo "現在のディレクトリは誤っています。"
        return 1
    fi
}
```

## 0607_TIL作成用
```
# TIL起動
til() {
  cd TIL
  git pull origin main
  code .
}
```
```
# Tilコミットメッセージ
# 引数にコミットメッセージのコメントを""で囲って記載
til_cm() {
    local current_dir=$(pwd)
    local commit_message="$1"
    
    # 引数チェック
    if [ -z "$commit_message" ]; then
        echo "使用方法: til_cm <"コミットメッセージ">"
        return 1
    fi
    
    # ディレクトリチェック
    if [ "$current_dir" = "ローカルのTILディレクトリ" ]; then
        git add .
        git commit -m "$commit_message"
        git status
    else
        echo "現在のディレクトリは誤っています。"
        return 1
    fi
}
```
## mmdd
### テンプレ