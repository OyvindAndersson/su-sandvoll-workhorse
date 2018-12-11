// webpack.config.js

const path = require('path');
const VueLoaderPlugin = require('vue-loader/lib/plugin')

module.exports = {
	entry: './js/index.js', 
	output: {
		path: path.resolve(__dirname, 'js'),
		filename: 'shared.bundle.js'
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