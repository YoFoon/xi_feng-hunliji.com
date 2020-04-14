#!/usr/bin/env sh

# basepath=$(cd `dirname $0`; pwd)
# sourcePath=$basepath'/docs/.vuepress/dist/'

# 终止一个错误
set -e

# 构建
npm run build

# 进入生成的构建文件夹
cd docs/.vuepress/dist

git init
git add -A
git commit -m 'deploy'

# 如果你想要部署到 https://<USERNAME>.github.io
# git push -f https://github.com/YoFoon/fe-face.git master

# 如果你想要部署到 https://<USERNAME>.github.io/<REPO>
git push -f https://github.com/YoFoon/fe-face.git master:gh-pages
# git push -f git@github.com:<USERNAME>/<REPO>.git master:gh-pages

cd -