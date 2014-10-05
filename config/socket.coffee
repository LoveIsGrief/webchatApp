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
				theUser =  new User(event.newName)

			users[event.newName] = theUser

			debug "change name: done"

			# Broadcast it to others!
			for chatroom, socketO in theUser.chatrooms
				io.to(chatroom).emit "change name", event

			# Notify ourself as well
			socket.emit "change name", event

			# Set name in socket
			socket["_username"] = event.newName


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
				users[user] = new User(user)
				debug "had to create new user"
				socket["_username"] = user

			chatroom = event.chatroom
			debug "#{user} joining chatroom: #{chatroom}"
			socket.join chatroom

			# Create chatroom-object and socket if need be
			chatroomO = users[user].chatrooms[chatroom] || {}
			chatroomO[socket.id] = 1
			users[user].chatrooms[chatroom] = chatroomO

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
			# Get username with socket assoc
			users = app.get("users")
			user = socket["_username"]

			debug "disconnecting #{user} with id: #{socket.id}"

			if not user
				user = "Unnamed user"
			else
				userO = users[user]
				debug users

				# If all this user's sockets have left a chatroom
				# broadcast it to others
				socketChatrooms = userO.chatroomsOfSocket socket
				debug "Socket chatrooms: #{socketChatrooms}"
				broadcastChatrooms = socketChatrooms.filter (room)->
					chatroomO = userO.chatrooms[room]
					delete chatroomO[socket.id]
					Object.isEmpty chatroomO

				debug "to broadcast disconnect to: #{broadcastChatrooms}"
				# Get rid of chatrooms no sockets are in
				for chatroom in broadcastChatrooms
					delete userO.chatrooms[chatroom]


				debug userO
				# We are in no chatroom anymore which means suicide
				if Object.isEmpty userO.chatrooms
					delete users[user]
					debug "deleted #{user}"
					debug users

				for chatroom in broadcastChatrooms
					debug "broadcast #{user} disconnect to #{chatroom}"
					io.to(chatroom).emit "user disconnect", user

			debug "#{user} disconnected"