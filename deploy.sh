#!/usr/bin/env sh

# basepath=$(cd `dirname $0`; pwd)
# sourcePath=$basepath'/docs/.vuepress/dist/'

# 终止一个错误
set -e

# 构建
npm run build

# 进入生成的构建文件夹
cd docs/.vuepress/dist

# 如果你是要部署到自定义域名
# echo 'www.cxymsg.com/fed' > CNAME

# echo "添加代码"
# cd $sourcePath
# sed -i '' '/<html/a\
# <script>var _hmt = _hmt || [];(function() {var hm = document.createElement("script");hm.src = "https://hm.baidu.com/hm.js?009a2f9b8cfc23cb5722f109462e450f";var s = document.getElementsByTagName("script")[0]; s.parentNode.insertBefore(hm, s);})();</script>' index.html
# echo "添加代码执行完毕"

git init
git add -A
git commit -m 'deploy'

# 如果你想要部署到 https://<USERNAME>.github.io
git push -f git@github.com:xiaomuzhu/xiaomuzhu.github.io.git master

# 如果你想要部署到 https://<USERNAME>.github.io/<REPO>
# git push -f git@github.com:<USERNAME>/<REPO>.git master:gh-pages

cd -