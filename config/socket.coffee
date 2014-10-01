module.exports = (app, io) ->

	# TODO make this an app global attribute (app.set "users" users)
	users = {
		# user: [chatrooms]
	}

	io.on "connection", (socket) ->
		console.log "a user(#{socket.id}) connected"

		getUsersInChatroom = (chatroom)->
			ret = Object.keys users
			ret.filter (user)->
				users[user].indexOf(chatroom) > -1

		socket.on "disconnect", ->
			console.log "user disconnected"

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
			chatrooms = unless users[user]
					users[user] = []
				else
					users[user]
			chatrooms.push chatroom

			io.to(chatroom).emit "chatroom users",
					getUsersInChatroom(chatroom)

		# Handle incoming chat messages
		# Save them and broadcast them to chatroom members
		socket.on "chat message", (message)->
			console.log "#{message.sender}: #{message.message}"

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
			# user = socket.cookie.name

			# TODO Notify users in different chatrooms
			# for chatroom in users[user]
			# 	io.to(chatroom).emit "user disconnect", user

			# TODO Remove user from users
			# delete users[user]