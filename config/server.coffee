# Prepares backend to startup
# Easy to reuse in tests

express = require "express"
config = require "./config"
app = express()


require("./express") app, config

http = require("http").Server app
io = require("socket.io") http

 # configure socket.io
require("./socket") app, io

module.exports = {
	http: http
	app: app
	io: io
	config: config
}