#!/bin/bash
set -e

if [ $# -gt 0 ]; then
    project=$1
else
    echo "Error: No project name given."
    exit 1
fi

echo "Creating project $project..."
mkdir "$project"
cd "$project"


echo "Initalizing project..."
git init
npm init -f


echo "Creating README and .gitignore files..."
echo "# ${project}" | cat - "$(dirname "../${BASH_SOURCE[0]}")/readme.tmpl.md" > ./README.md
cp "$(dirname "../${BASH_SOURCE[0]}")/.gitignore.tmpl" ./.gitignore


echo "Initalizing Webpack and Babel..."
npm install --save-dev \
    webpack \
    webpack-dev-server \
    webpack-cli \
    html-webpack-plugin \
    @babel/core \
    @babel/preset-env \
    @babel/preset-react \
    babel-loader \
    mini-css-extract-plugin \
    css-loader
npm install --save @babel/polyfill

cp "$(dirname "../${BASH_SOURCE[0]}")/webpack.config.tmpl.js" ./webpack.config.js
cp "$(dirname "../${BASH_SOURCE[0]}")/.babelrc.tmpl" ./.babelrc

tmp=$(mktemp)
jq '.scripts += { build: "webpack --mode production", client: "webpack-dev-server --mode development" }' package.json > "$tmp" && mv "$tmp" package.json


echo "Initalizing ESLint and Prettier..."
npm install --save-dev \
    eslint \
    eslint-plugin-import \
    eslint-plugin-react \
    eslint-plugin-prettier \
    eslint-config-prettier \
    babel-eslint \
    eslint-plugin-babel \
    prettier
cp "$(dirname "../${BASH_SOURCE[0]}")/.eslintrc.tmpl" ./.eslintrc


echo "Initializing Flow typing..."
npm install --save-dev \
    flow-bin \
    @babel/preset-flow \
    eslint-plugin-flowtype \
    eslint-plugin-flowtype-errors

tmp=$(mktemp)
jq '.scripts += { flow: "flow" }' package.json > "$tmp" && mv "$tmp" package.json

npm run flow init


echo "Initializing React client entry..."
npm install --save react react-dom
cp -R "$(dirname "../${BASH_SOURCE[0]}")/client" .


echo "Initalizing Express backend..."
npm install --save express
cp "$(dirname "../${BASH_SOURCE[0]}")/app.tmpl.js" ./app.js

tmp=$(mktemp)
jq '.scripts += { server: "node app.js" }' package.json > "$tmp" && mv "$tmp" package.json
