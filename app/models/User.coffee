class User
	constructor: (@name, chatrooms, sockets) ->
		@chatrooms = chatrooms || []
		@sockets = sockets || []

module.exports = User