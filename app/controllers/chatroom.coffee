express  = require "express"
router = express.Router()

module.exports = (app) ->

	router.get "/:chatroom", (req, res, next) ->
		chatroomName = req.params.chatroom
		if chatroom = app.get("chatrooms")[chatroomName]
			res.send chatroom
		else
			res.status(404).send "Chatroom not found"

	# Creates a chatroom if inexistent
	# Returns one if it is
	# Errors if chatroom param isn"t given
	router.post "/:chatroom", (req, res, next) ->


		if chatroomName = req.params.chatroom
			chatrooms = app.get("chatrooms")
			chatroom = chatrooms[chatroomName]
			status = 200
			if not chatroom
				console.log "Creating new chatroom"
				chatroom = {
					name: chatroomName
					chatroom: {messages: []}
				}
				chatrooms[chatroomName] = chatroom

			res.status(status).send chatroom

		else
			res.sendStatus 400 # Bad request

	# Attempts to retrieve a chatroom
	# returns all chatrooms if no chatroom is given
	router.use (req, res, next) ->
		if Object.keys(req.params).length == 0
			console.log Object.keys(app.get "chatrooms")
			res.send Object.keys(app.get "chatrooms")
		else
			console.log req.params
			next()

	# deleting a chatroom is done by socket.io
	# when everyone exits a chatroom

	app.use "/api/chatrooms/", router

