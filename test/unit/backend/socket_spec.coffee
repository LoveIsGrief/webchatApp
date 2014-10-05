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

# Start up the server
http.listen config.port, ->
	debug "Http server listening"

describe 'a socket.io user', ->

	# Setup client-side socket.io
	beforeEach ->

		socketClient = require "socket.io-client"
		@socket = socketClient "http://localhost:#{config.port}", {
			reconnection: false
			multiplex: false
		}
		debug "created client socket"

	describe "during session initialization and establishment" , ->

		it 'should connect', (done)->
			debug "should connect"
			@socket.on "connect", ->
				done()

		it "should create user on first name change", (done)->
			@socket.on "change name", (event)->
				expect(event.newName).toEqual "herp"
				# New user should be in backend
				expect(app.get("users")["herp"]).toBeTruthy()
				done()
			@socket.emit "change name", { oldName: null, newName: "herp"}

	describe "after initializing and picking a name" , ->

		beforeEach ->

			app.set "users", {}
			@users = app.get "users"

			# Add a user to the app
			@username = "herp"
			@users[@username] = new User(@username)

		it "should change their name again", (done)->

			oldName = @username
			newName = "derp"
			oldUser = @users[@username]

			# Change name a second time
			@socket.once "change name", (event)->

				# Old user name should be deleted from backend
				expect(app.get("users")[oldName]).toBeUndefined()

				# New user name should be in backend
				renamedUser = app.get("users")[newName]
				expect(renamedUser).toBeDefined()
				expect(renamedUser).toEqual oldUser
				done()

			# Initiate second name change
			@socket.emit "change name", { oldName: oldName, newName: newName}

		it "should join a chatroom" , (done) ->
			chatroom = "offtopic"
			@socket.on "chatroom users", (users)=>
				expect(users).toContain @username
				expect(@users[@username].chatrooms).toContain chatroom
				done()

			@socket.emit "join chatroom", { who: @username, chatroom: chatroom }

	describe "in an established session in offtopic chatroom" , ->

		beforeEach (done)->

			# Reset users
			app.set "users", {}
			@users = app.get "users"

			# Add a user to the app
			@username = "herp"
			@chatroom = "offtopic"
			@users[@username] = new User(@username, [])

			@socket.on "chatroom users", (users)=>
				done()

			@socket.emit "join chatroom", { who: @username, chatroom: @chatroom }

		it "should send a chat message", (done)->
			message = {
				sender: @username
				content: "Herp to derp!"
				chatroom: @chatroom
			}

			@socket.on "chat message", (broadcastMessage)->
				expect(broadcastMessage.sender).toEqual message.sender
				expect(broadcastMessage.for).toEqual message.chatroom
				expect(broadcastMessage.content).toEqual message.content

				done()

			@socket.emit "chat message", message

	describe "exiting" , ->

		it "should disconnect", (done)->
			@socket.once "disconnect", ->
				done()
			@socket.on "connect", =>
				debug "connected to disconnect"
				@socket.disconnect()
				debug "disconnecting client socket"


	# Tear down socket.io client
	afterEach ->
		debug "before disconnect after end"
		@socket.disconnect()
		debug "disconnected after end"
