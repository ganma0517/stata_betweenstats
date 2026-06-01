#!/bin/bash
#===============================================================
# betweenstats 一鍵推送腳本（雙擊即可執行）
# 首次使用前：
#   1) 到 https://github.com/new 建立 Public 倉庫，名稱填 stata_betweenstats
#      （不要勾任何初始檔）
#   2) 把下面 PUT_TOKEN_HERE 換成有效的 classic token（ghp_開頭、勾 repo）
#===============================================================
TOKEN="PUT_TOKEN_HERE"
USER="ganma0517"
REPO="stata_betweenstats"
EMAIL="jay8956047@gmail.com"
NAME="Wen-Cheng Lin"

cd "$(dirname "$0")" || exit 1
echo "==> 專案資料夾: $(pwd)"
rm -f .git/index.lock .git/HEAD.lock .git/config.lock .git/refs/remotes/origin/main.lock 2>/dev/null

if [ ! -d .git ]; then
  git init
  git branch -M main
fi
git config user.email "$EMAIL"
git config user.name  "$NAME"

git add -A
git commit -m "update betweenstats" || echo "（沒有新變更可提交）"

if [ "$TOKEN" != "PUT_TOKEN_HERE" ] && [ -n "$TOKEN" ]; then
  URL="https://${USER}:${TOKEN}@github.com/${USER}/${REPO}.git"
  if git remote | grep -q origin; then git remote set-url origin "$URL"; else git remote add origin "$URL"; fi
else
  echo "！！ 尚未填入 token：請編輯本檔，把 PUT_TOKEN_HERE 換成有效 token 後再執行。"
fi

git push -u origin main
echo ""
echo "==> 完成。若看到 'main -> main' 即成功。"
read -n 1 -s -r -p "按任意鍵關閉視窗..."
