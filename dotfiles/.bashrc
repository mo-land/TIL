# docker立ち上げ
alias dc='docker compose'
alias dcb='docker compose build'
alias dcu='docker compose up'
alias dcbi='docker compose exec web bundle install'
alias dcyi='docker compose run web yarn install'
alias dcbd='docker compose exec web bin/dev'

alias dbsh='docker compose exec web bash'
alias fixown='sudo chown -R $USER:$USER .'

# docker終了・再起動
alias dcd='docker compose down'
alias dcr='docker compose restart'

# dockerマイグレーション系
alias dcrg='docker compose run web rails g'
alias dcrdm='docker compose exec web rails db:migrate'

# dockerテスト系
alias dcbrb='docker compose exec web bundle exec rubocop'
alias dcbrs='docker compose exec web bundle exec rspec'

# dockerテストファイル作成
# 末尾にモデル名（例：Question）を追加
alias dcgrm='docker compose exec web bundle exec rails generate rspec:model'
# 末尾にコントローラー名（例：questions）を追加
alias dcgrc='docker compose exec web bundle exec rails g rspec:request'

# dockerデバッグ系
alias dp='docker ps'
alias dcrc='docker compose exec web rails c'

#git ローカル作業開始前
alias gb='git branch'
alias gs='git switch'
alias gs-='git switch -'
alias gpllo='git pull origin'
alias gcb='git checkout -b'

#git コミット
alias ga='git add'
alias gcm='git commit -m '

#git プッシュ
alias gpsho='git push origin'

# Win権限対応
alias scr='sudo chown -R $USER:$USER .'

# history beginning search
# 上矢印キー
bind '"\e[A": history-search-backward'
# 下矢印キー
bind '"\e[B": history-search-forward'

#.bashrcのファイルをvimで開く
alias vbsh='vi ~/.bashrc'

# .bash_profileのファイルをvimで開く
# 開いたら'source ~/.bashrc'を記述
alias vbpf='vi ~/.bash_profile'

# .bashrcの変更を反映
alias sbsh='source ~/.bashrc'