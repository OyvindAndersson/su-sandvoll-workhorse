// webpack.config.js

const path = require('path');
const VueLoaderPlugin = require('vue-loader/lib/plugin')

module.exports = {
	entry: {
		//shared: './js/index.js',
		layout: './js/modules/layout/index.js',
		layers: './js/modules/layers/index.js',
		nameinc:'./js/modules/nameinc/index.js'
	}, 
	output: {
		library: 'SKPClientLib',
		libraryExport: 'default',
		libraryTarget: 'var',
		path: path.resolve(__dirname, './build'),
		filename: '[name].bundle.js'
	},
	module: {
		rules: [
			{
				test: /\.js$/,
				exclude: /node_modules/,
				loader: 'babel-loader'
			},
			{
				test: /\.vue$/,
				loader: 'vue-loader'
			},
			{
				test: /\.css$/,
				use: [
					'vue-style-loader',
					'css-loader'
				]
			},
			{
				test: /\.scss$/,
				use: [
					'vue-style-loader',
					'css-loader',
					'sass-loader'
				]
			}
		]
	},
	resolve: {
		alias: {
			'vue$': 'vue/dist/vue.common.js'
		},
		extensions: ['*', '.js', '.vue', '.json']
	},
	plugins: [
		// make sure to include the plugin!
		new VueLoaderPlugin()
	]
}

/*
module: {
  rules: [
    { test: /\.js$/, exclude: /node_modules/, loader: "babel-loader" }
  ]
}
*/