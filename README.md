# Project Bootstrap
An opinionated tool for quickly setting up web development projects.

This project is intended for personal use, and therefore makes assumptions about setup and preferences that may not be broadly applicable.

## Stack
* React
* Express
* Git
* npm
* Webpack
* Flow
* Eslint
* Prettier

## Setup
1. Install [jq](https://stedolan.github.io/jq/download/) with `brew install jq`
1. Install [gettext](https://www.gnu.org/software/gettext/manual/html_node/envsubst-Invocation.html) with `brew install gettext && brew link --force gettext`
1. Run `setup.sh $PROJECT_NAME` in the directory that you would like to contain your project directory.

### Environment variables
`API_ENDPOINT` - Sets the api prefix on the backend server. Defaults to `api`.
