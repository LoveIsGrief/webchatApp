express  = require 'express'
router = express.Router()

module.exports = (app) ->

	# Attempts to retrieve a chatroom
	# returns all chatrooms if no chatroom is given
	router.use (req, res, next) ->
		if Object.keys(req.params).length == 0
			console.log get "chatrooms"
			res.send app.get "chatrooms"
		else
			console.log req.params
			next()

	router.get '/:chatroom', (req, res, next) ->
		console.log "here"
		if chatroom = app.get("chatrooms")[chatroomName]
			console.log chatroom
			res.send chatroom
		else
			res.status(404).send "Chatroom not found"

	# Creates a chatroom if inexistent
	# Returns one if it is
	# Errors if chatroom param isn't given
	router.post "/:chatroom", (req, res, next) ->


		if chatroomName = req.params.chatroom
			chatrooms = app.get("chatrooms")
			chatroom = chatrooms[chatroomName]
			status = 200
			if not chatroom
				chatroom = {
					name: chatroomName
					chatroom: {messages: []}
				}
				chatrooms[chatroomName] = chatroom

			res.status(status).send chatroom

		else
			res.sendStatus 400 # Bad request

	# deleting a chatroom is done by socket.io
	# when everyone exits a chatroom

	app.use '/api/chatrooms/', router

