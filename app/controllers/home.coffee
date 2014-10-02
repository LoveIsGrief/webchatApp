express  = require "express"
router = express.Router()

module.exports = (app) ->
	app.use "/", router

router.use (req, res, next) ->

	if Object.isEmpty(req.cookies)
		console.log "Initializing username"
		res.cookie "username", ""

	res.render "index"