#!/bin/bash
set -e

if [ $# -gt 0 ]; then
    project=$1
else
    echo "Error: No project name given."
    exit 1
fi

command -v envsubst >/dev/null 2>&1 || { echo >&2 "Error: envsubst is not available."; exit 1; }
command -v jq >/dev/null 2>&1 || { echo >&2 "Error: jq is not available."; exit 1; }

export API_ENDPOINT=${API_ENDPOINT:=api}

if [[ -L "${BASH_SOURCE[0]}" ]];
then
    sourcedir=$( dirname $(readlink ${BASH_SOURCE[0]}) )
else
    sourcedir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
fi

echo "Creating project $project..."
mkdir -p "$project"
pushd "$project" >/dev/null


echo "Initalizing project..."
git init
npm init -f


echo "Creating README and .gitignore files..."
echo "# ${project}" | cat - "$sourcedir/readme.tmpl.md" > ./README.md
cp "$sourcedir/.gitignore.tmpl" ./.gitignore


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

envsubst '$API_ENDPOINT' < "$sourcedir/webpack.config.tmpl.js" > ./webpack.config.js
cp "$sourcedir/.babelrc.tmpl" ./.babelrc

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
cp "$sourcedir/.eslintrc.tmpl" ./.eslintrc


echo "Initializing Flow typing..."
npm install --save-dev \
    flow-bin \
    @babel/preset-flow \
    eslint-plugin-flowtype \
    eslint-plugin-flowtype-errors
npx flow init


echo "Initializing React client entry..."
npm install --save react react-dom
cp -R "$sourcedir/client" .
envsubst '$API_ENDPOINT' < "$sourcedir/client/src/app.jsx" > ./client/src/app.jsx


echo "Initalizing Express backend..."
npm install --save express
npm install --save-dev nodemon @babel/node
mkdir -p server/src
envsubst '$API_ENDPOINT' < "$sourcedir/app.tmpl.js" > ./server/src/app.js

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
