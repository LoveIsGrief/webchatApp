module.exports = (app, io) ->

	cookie = require "cookie"
	app.set "users", users = {
		# user: {chatrooms: []}
		# TODO: track which other sockets are being used by the user
	}

	getUsersInChatroom = require("../util/getUsersInChatroom")(app)

	io.on "connection", (socket) ->
		console.log "a user(#{socket.id}) connected"


		# TODO handle username change
		# Broadcast it to others!

		# Handle newcomers to chatroom
		# Register them app-globally and broadcast their presence
		socket.on "join chatroom", (event)->
			user = event.who
			return unless user
			chatroom = event.chatroom
			console.log "#{user} joining chatroom: #{chatroom}"
			socket.join chatroom

			# TODO Set username in cookie

			# Register user and their chatroom
			unless users[user]
					users[user] = { chatrooms: []}
			chatrooms = users[user].chatrooms
			chatrooms.push chatroom

			io.to(chatroom).emit "chatroom users",
					getUsersInChatroom(chatroom)

		# Handle incoming chat messages
		# Save them and broadcast them to chatroom members
		socket.on "chat message", (message)->
			console.log "#{message.sender}: #{message.message}"
			console.log socket.request.headers.cookie

			dbMessage = {
				for: message.chatroom
				datetime: (new Date()).toJSON()
				sender: message.sender
				content: message.message
			}

			app.get("chatrooms")[message.chatroom].messages.push dbMessage

			io.to(message.chatroom).emit "chat message", dbMessage

		socket.on "disconnect", ->

			# They are dead to us!
			# TODO get username from cookie
			user = socket.request.headers.cookie.username || "Unnamed user"
			console.log "#{user} disconnected"

			# for chatroom in users[user]
				# TODO If no other sockets owned by this user are in the same chatroom
				# TODO Leave it and notify others of departure
				# TODO Notify users in different chatrooms
				# io.to(chatroom).emit "user disconnect", user

			# TODO If last socket: remove user from users
			# delete users[user]