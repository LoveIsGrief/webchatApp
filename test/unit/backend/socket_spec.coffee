root = "../../../"

process.env.NODE_ENV = "test"

debug = require("debug")("test")
server = require "#{root}config/server"
config = server.config
http = server.http
app = server.app

# Start up the server
http.listen config.port, ->
	debug "Http server listening"


describe 'socket.io test suite', ->

	# Setup client-side socket.io
	beforeEach ->

		socketClient = require "socket.io-client"
		@socket = socketClient "http://localhost:#{config.port}", {
			reconnection: false
			multiplex: false
		}
		debug "created client socket"


	it 'should connect', (done)->
		debug "should connect"
		@socket.on "connect", ->
			debug "yay"
			done()

	it "should disconnect", (done)->
		@socket.on "disconnect", ->
			done()
		@socket.on "connect", =>
			debug "connected to disconnect"
			@socket.disconnect()
			debug "disconnecting client socket"

	it "should change name first time", (done)->
		@socket.on "change name", (event)->
			expect(event.newName).toEqual "herp"
			# New user should be in backend
			expect(app.get("users")["herp"]).toBeTruthy()
			done()
		@socket.emit "change name", { oldName: null, newName: "herp"}


	it "should change name two times", (done)->
		@socket.once "change name", (event)=>
			expect(event.newName).toEqual "herp"
			# New user should be in backend
			oldUser = app.get("users")["herp"]
			expect(oldUser).toBeTruthy()

			# Change name a second time
			@socket.once "change name", (event)->
				debug app.get("users")
				# Old user name should be deleted from backend
				expect(app.get("users")["herp"]).toBeFalsy()
				# New user name should be in backend
				renamedUser = app.get("users")["derp"]
				expect(renamedUser).toBeTruthy()
				expect(renamedUser).toEqual oldUser
				done()

			# Initiate second name change
			@socket.emit "change name", { oldName: "herp", newName: "derp"}

		# Initiate first name change
		@socket.emit "change name", { oldName: null, newName: "herp"}

	# Tear down socket.io client
	afterEach ->
		debug "before disconnect after end"
		@socket.disconnect()
		debug "disconnected after end"