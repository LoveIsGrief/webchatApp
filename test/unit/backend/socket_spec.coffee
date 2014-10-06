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
			debug "should create user on first name change"
			@socket.on "change name", (event)->
				expect(event.newName).toEqual "herp"
				# New user should be in backend
				expect(app.get("users")["herp"]).toBeTruthy()
				done()
			@socket.emit "change name", { oldName: null, newName: "herp"}

	describe "after initializing and picking a name" , ->

		beforeEach (done)->

			@users = app.get "users"

			# Add a user to the app
			@username = "herp"
			@socket.once "change name", (event)->
				done()
			@socket.emit "change name", { oldName: null, newName: @username}

		it "should change their name again", (done)->

			oldName = @username
			newName = "derp"
			oldUser = @users[oldName]

			# Change name a second time
			@socket.once "change name", (event)->

				# Old user name should be deleted from backend
				expect(app.get("users")[oldName]).toBeUndefined()

				# New user name should be in backend
				renamedUser = app.get("users")[newName]
				expect(renamedUser).toBeDefined()
				done()

			# Initiate second name change
			@socket.emit "change name", { oldName: oldName, newName: newName}

		it "should join a chatroom" , (done) ->
			debug "should join a chatroom"
			chatroom = "offtopic"
			@socket.on "chatroom users", (users)=>
				expect(users).toContain @username
				expect(@users[@username].chatrooms[chatroom]).toBeDefined()
				done()

			@socket.emit "join chatroom", { who: @username, chatroom: chatroom }

	describe "in an established session in offtopic chatroom" , ->

		beforeEach (done)->

			# Reset users
			@users = app.get "users"

			# Add a user to the app
			@username = "herp"
			@chatroom = "offtopic"

			@socket.on "chatroom users", (users)=>
				debug "beforeEach joined chatroom"
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

		it "should disconnect and exit chatroom" , (done)->

			# No callback on server so we have to wait a wee little bit
			setTimeout =>
				debug "checking user existence"
				debug Object.keys(app.get("users"))
				debug @username
				# expect(Object.keys(app.get("users"))).not.toContain @username
				done() #TODO find out why this isn't being called...
				debug "called done!"
			, 50


			debug "disconnecting and leaving chatroom"
			@socket.disconnect()

	describe "in an established session in offtopic chatroom with another user" , ->

		beforeEach (done)->

			# Reset users
			# app.set "users", {}
			@users = app.get "users"

			# Add a user to the app
			@username = "herp"
			@chatroom = "offtopic"
			@users[@username] = new User(@username, [])

			@socketA.on "chatroom users", (users)=>
				done()

			@socketA.emit "join chatroom", { who: @username, chatroom: @chatroom }

			# socket2 =

		xit "should disconnect and broadcast to others" , ->

	describe "exiting" , ->

		it "should disconnect", (done)->
			@socket.once "disconnect", ->
				debug "socket disconnected"
				done() #TODO find out why this isn't being called...
			@socket.on "connect", =>
				debug "connected to disconnect"
				@socket.disconnect()
				debug "disconnecting client socket"


	# Tear down socket.io client
	afterEach (done)->
		debug "before disconnect after end"
		@socket.once "disconnect", ->
			debug "disconnected after end"
			done()
		@socket.disconnect()
