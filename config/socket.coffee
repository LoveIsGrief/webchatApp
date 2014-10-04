module.exports = (app, io) ->

	cookie = require "cookie"
	app.set "users", users = {
		# user: {chatrooms: []}
		# TODO: track which other sockets are being used by the user
	}

	getUsersInChatroom = require("../util/getUsersInChatroom")(app)

	io.on "connection", (socket) ->
		console.log "a user(#{socket.id}) connected"

		###
		User changed name -->
			Rename or add user in app-store
			Broadcast change to others
		@param event [Object] { oldName: [String], newName: [String]}
		###
		socket.on "change name", (event)->

			console.log "changing name: #{JSON.stringify event}"

			# Rename user in app-store
			theUser = users[event.oldName] || { chatrooms: []}
			delete users[event.old] if theUser
			users[event.newName] = theUser

			# Broadcast it to others!
			for chatroom in theUser.chatrooms
				io.to(chatroom).emit "change name", event


		###
		Handle newcomers to chatroom
		Register them app-globally and broadcast their presence
		@param event [Object] { who: [String], chatroom: [String]}
		###
		socket.on "join chatroom", (event)->
			# Checks on the user
			user = event.who
			return unless user
			unless users[user]
				users[user] = { chatrooms: []}

			chatroom = event.chatroom
			console.log "#{user} joining chatroom: #{chatroom}"
			socket.join chatroom

			users[user].chatrooms.push chatroom
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
			user = if cookie = socket.request.headers.cookie
					cookie.username || "Unnamed user"
				else
					"Unnamed user"
			console.log "#{user} disconnected"

			# for chatroom in users[user]
				# TODO If no other sockets owned by this user are in the same chatroom
				# TODO Leave it and notify others of departure
				# TODO Notify users in different chatrooms
				# io.to(chatroom).emit "user disconnect", user

			# TODO If last socket: remove user from users
			# delete users[user]