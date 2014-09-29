express  = require "express"
router = express.Router()

module.exports = (app) ->
  app.use "/", router

router.use (req, res, next) ->

    res.render "index",
      title: "Chatrooms"
