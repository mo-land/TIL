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