#!/bin/bash
set -e

if [ $# -gt 0 ]; then
    project=$1
else
    echo "Error: No project name given."
    exit 1
fi

export API_ENDPOINT=${API_ENDPOINT:=api}

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
    @babel/cli \
    @babel/core \
    @babel/preset-env \
    @babel/preset-react \
    @babel/plugin-transform-runtime \
    @babel/runtime \
    babel-loader \
    mini-css-extract-plugin \
    css-loader
npm install --save @babel/polyfill

envsubst '$API_ENDPOINT' < "$(dirname "../${BASH_SOURCE[0]}")/webpack.config.tmpl.js" > ./webpack.config.js
cp "$(dirname "../${BASH_SOURCE[0]}")/.babelrc.tmpl" ./.babelrc

tmp=$(mktemp)
jq '.scripts += {
    "build:client": "webpack --mode production",
    "start:client": "webpack-dev-server --mode development" }' \
package.json > "$tmp" && mv "$tmp" package.json


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
npx flow init


echo "Initializing React client entry..."
npm install --save react react-dom
cp -R "$(dirname "../${BASH_SOURCE[0]}")/client" .
envsubst '$API_ENDPOINT' < "$(dirname "../${BASH_SOURCE[0]}")/client/src/app.jsx" > ./client/src/app.jsx


echo "Initalizing Express backend..."
npm install --save express
npm install --save-dev nodemon @babel/node
mkdir -p server/src
envsubst '$API_ENDPOINT' < "$(dirname "../${BASH_SOURCE[0]}")/app.tmpl.js" > ./server/src/app.js

tmp=$(mktemp)
jq '.scripts += {
    "build:server": "babel ./server/src --out-dir ./server/dist --delete-dir-on-start",
    "start:server": "nodemon --exec babel-node server/src/app.js",
    start: "node server/dist/app.js" }' \
package.json > "$tmp" && mv "$tmp" package.json


echo "Adding additional build scripts..."
tmp=$(mktemp)
jq '.scripts += {
    build: "npm run build:client && npm run build:server",
    postinstall: "npm run build" }' \
package.json > "$tmp" && mv "$tmp" package.json
