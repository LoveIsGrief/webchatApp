module.exports = (app, io) ->

	io.on "connection", (socket) ->
		console.log "a user(#{socket.id}) connected"

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