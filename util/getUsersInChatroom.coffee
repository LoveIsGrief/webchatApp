module.exports = (app)->

	###
	@return all users in given chatroom
	###
	(chatroom)->
		users = app.get("users")
		ret = Object.keys users
		ret.filter (user)->
			users[user].indexOf(chatroom) > -1