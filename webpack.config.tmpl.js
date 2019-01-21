const webpack = require('webpack')
const path = require('path')
const HtmlWebpackPlugin = require('html-webpack-plugin')
const MiniCssExtractPlugin = require('mini-css-extract-plugin')

const paths = {
  CLIENT_DIST: path.resolve(__dirname, 'client/dist'),
  CLIENT: path.resolve(__dirname, 'client/src'),
}

module.exports = {
  entry: ['@babel/polyfill', path.join(paths.CLIENT, 'app.jsx')],
  output: {
    path: paths.CLIENT_DIST,
    filename: 'app.bundle.js',
  },
  plugins: [
    // Helper to inject the app into index.html
    new HtmlWebpackPlugin({
      template: path.join(paths.CLIENT, 'index.html'),
    }),
    // CSS bundler
    new MiniCssExtractPlugin({ filename: 'style.bundle.css' }),
    // Enable hot reloading
    new webpack.HotModuleReplacementPlugin(),
  ],
  module: {
    rules: [
      // Use Babel for JS files
      {
        test: /\.(js|jsx)$/,
        exclude: /node_modules/,
        use: ['babel-loader'],
      },
      // CSS loader to allow css importing
      {
        test: /\.css$/,
        use: [
          MiniCssExtractPlugin.loader,
          {
            loader: 'css-loader',
            options: { modules: true },
          },
        ],
      },
    ],
  },
  // Enable importing JS files without an extension
  resolve: {
    extensions: ['.js', '.jsx'],
  },
  // Server for local JS development
  devServer: {
    proxy: {
      // Enabled local development with a backend
      // https://webpack.js.org/configuration/dev-server/#devserver-proxy
      '/api': {
        target: 'http://localhost:3000',
        secure: false,
      },
    },
    hot: true,
  },
}
