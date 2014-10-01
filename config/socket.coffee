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

		socket.on "join chatroom", (chatroom)->
			console.log "joining chatroom: #{chatroom}"
			socket.join chatroom

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