var path = require('path')
var ExtractTextPlugin = require('extract-text-webpack-plugin')
var CopyWebpackPlugin = require('copy-webpack-plugin')
var webpack = require('webpack')
var env = process.env.MIX_ENV || 'dev'
var isProduction = (env === 'prod')
const elmSource = __dirname + '/elm'

module.exports = {
    entry: {
        'app': ['./js/app.js', './elm/Main.elm', './css/app.css']
    },
    output: {
        path: path.resolve(__dirname, '../priv/static/'),
        filename: 'js/[name].js'
    },
    devtool: 'source-map',
    resolve: {
        extensions: ['.js', '.css', '.scss', '.elm']
    },
    module: {
        rules: [{
            test: /\.(sass|css)$/,
            include: /css/,
            use: ExtractTextPlugin.extract({
                fallback: 'style-loader',
                use: [
                    { loader: 'css-loader' },
                    {
                        loader: 'sass-loader',
                        options: {
                            sourceComments: !isProduction
                        }
                    }
                ]
            })
        }, {
            test: /\.(js)$/,
            include: /js/,
            use: [
                { loader: 'babel-loader' }
            ]
        },
        {
            test: /\.elm$/,
            exclude: ['/elm-stuff/', '/node_modules'],
            loader: 'elm-webpack-loader?cwd=' + elmSource
        }],
        noParse: [/\.elm$/]
    },
    plugins: [
        new CopyWebpackPlugin([{ from: './static' }]),
        new ExtractTextPlugin('css/app.css'),
        new webpack.ProvidePlugin({
            $: "jquery",
            jQuery: "jquery",
            "window.jQuery": "jquery",
            Popper: ['popper.js', 'default']
        })
    ]
}