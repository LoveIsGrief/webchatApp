module.exports = (app, io) ->

	io.on "connection", (socket) ->
		console.log "a user connected"
		console.log socket.	client

		socket.on "chat message", (message)->
			console.log "#{message.sender}: #{message.message}"

			dbMessage = {
				datetime: (new Date()).toJSON()
				sender: message.sender
				content: message.message
			}

			app.get("chatrooms")[message.chatroom].messages.push dbMessage

			io.emit "chat message", dbMessage