require "sugar"
root = "../../../"

process.env.NODE_ENV = "test"

debug = require("debug")("test")

# Models
User = require "#{root}app/models/User"

# Server stuff
server = require "#{root}config/server"
config = server.config
http = server.http
app = server.app

describe "Webchat app" , ->


	describe 'initial app state', ->
		it 'to be alright :)', ->
			expect(app.get("chatrooms")).toBeDefined()
			expect(app.get("users")).toBeDefined()