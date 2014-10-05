class User
	constructor: (@name, chatrooms, sockets) ->
		@chatrooms = chatrooms || {
			# chatroom: { <socketId1>: 1 , ..., <socketIdN>: 1}
		}

	chatroomsOfSocket: (socket) =>
		id = socket.id

		names = Object.keys @chatrooms
		names.filter (name)=>
			# chatroomO.hasOwnProperty id
			@chatrooms[name].hasOwnProperty id


module.exports = User