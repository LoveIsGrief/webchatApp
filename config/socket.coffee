debug = require("debug")("webChatApp:socket")
User = require '../app/models/User'

module.exports = (app, io) ->

	cookie = require "cookie"
	getUsersInChatroom = require("../util/getUsersInChatroom")(app)

	io.on "connection", (socket) ->
		debug "a user(#{socket.id}) connected"

		###
		User changed name -->
			Rename or add user in app-store
			Broadcast change to others
		@param event [Object] { oldName: [String], newName: [String]}
		###
		socket.on "change name", (event)->
			users = app.get "users"
			debug "changing name: #{JSON.stringify event}"

			# Rename user in app-store
			theUser = users[event.oldName]
			debug "old user: #{JSON.stringify theUser}"


			if theUser
				debug "deleting old user: #{JSON.stringify theUser}"
				delete users[event.oldName]
			else
				# User doesn't exist, create new one
				theUser =  new User()
			users[event.newName] = theUser

			debug "change name: done"

			# Broadcast it to others!
			for chatroom in theUser.chatrooms
				io.to(chatroom).emit "change name", event

			# Notify ourself as well
			socket.emit "change name", event


		###
		Handle newcomers to chatroom
		Register them app-globally and broadcast their presence
		@param event [Object] { who: [String], chatroom: [String]}
		###
		socket.on "join chatroom", (event)->
			users = app.get "users"
			# Checks on the user
			user = event.who
			return unless user
			unless users[user]
				users[user] = new User()

			chatroom = event.chatroom
			debug "#{user} joining chatroom: #{chatroom}"
			socket.join chatroom

			users[user].chatrooms.push chatroom
			io.to(chatroom).emit "chatroom users",
					getUsersInChatroom(chatroom)

		# Handle incoming chat messages
		# Save them and broadcast them to chatroom members
		socket.on "chat message", (message)->
			debug "message from #{message.sender}: #{message.content}"

			dbMessage = {
				datetime: (new Date()).toJSON()
				sender: message.sender
				content: message.content
			}

			app.get("chatrooms")[message.chatroom].messages.push dbMessage

			# We don't want to change the db
			toSend = Object.clone dbMessage
			toSend.for = message.chatroom
			debug "broadcasting message #{JSON.stringify toSend}"
			io.to(message.chatroom).emit "chat message", toSend

		socket.on "disconnect", ->

			# They are dead to us!
			# TODO get username from cookie
			user = if cookie = socket.request.headers.cookie
					cookie.username || "Unnamed user"
				else
					"Unnamed user"
			debug "#{user} disconnected"

			# for chatroom in users[user]
				# TODO If no other sockets owned by this user are in the same chatroom
				# TODO Leave it and notify others of departure
				# TODO Notify users in different chatrooms
				# io.to(chatroom).emit "user disconnect", user

			# TODO If last socket: remove user from users
			# delete users[user]