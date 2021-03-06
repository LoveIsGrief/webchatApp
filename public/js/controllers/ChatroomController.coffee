chatroomControllers = angular.module "chatroomControllers", [ "ngCookies"]

# Used to control a list of chatrooms
ChatroomListController = ($scope, Chatroom) ->

	console.log "Created ChatroomListController"

	document.title = "Chatrooms"

	$scope.chatrooms = []
	$scope.chatroomFilter = ""

	# async call that returns a list of chatrooms from the backend
	Chatroom.query {}, (data) ->
		$scope.chatrooms = data
		console.log "got chatrooms"


chatroomControllers.controller( "ChatroomListController", ChatroomListController,
	["Chatroom"])


# Used to control 1 chatroom
ChatroomController = ($scope, Chatroom, $state, Socket, $cookies) ->

	#
	# Scope vars
	#

	console.log "Created ChatroomController"
	$scope.chatroom = { name: "", messages: []}

	# Need an object to pass through ng-if and similar scopes
	$scope.user = {
		name: $cookies.username
		tempName: "" # Temp store while changing the name
		changing: false # Indicates if we're changing the name
		validation: "" # Used by ng-class when creating a username
		message: ""
	}

	#
	# utility methods
	#

	sendJoinChatroom = (name)->
		Socket.emit "join chatroom", {
				who:  name
				chatroom: $scope.chatroom.name
			}

	isUserInChatroom = (user)->
		searched = user || $scope.user.name
		$scope.chatroom.users.indexOf(searched) > -1

	dateStringToDateTimeObject = (dateString)->
		date = Date.create dateString
		{
			time: date.format "{hh}:{mm}:{ss}.{ms}"
			date: date.format "{yyyy}-{mm}-{dd}"
		}

	#
	# scope methods
	#

	$scope.toggleUsernameChanging = ->
		console.log "Toggle user.changing"
		$scope.user.tempName = $scope.user.name
		$scope.user.changing = ! $scope.user.changing

	# Check if the username is unique to the server
	# @returns Boolean
	$scope.validateNewUsername = ->
		console.log "old username: #{$scope.user.name}"
		console.log "new username: #{$scope.user.tempName}"
		$scope.user.validation = "has-success"
		true #TODO implement validation

	$scope.changeUsername = ->
		return if not $scope.validateNewUsername

		console.log "Setting username to #{$scope.user.tempName}"

		# Notify of new name
		Socket.emit "change name", {
			oldName: $scope.user.name
			newName: $scope.user.tempName
		}

		# Join chatroom if user isn't in it
		unless isUserInChatroom()
			sendJoinChatroom $scope.user.tempName

		$cookies.username = $scope.user.name = $scope.user.tempName
		$scope.toggleUsernameChanging()

	$scope.sendMessage = ->
		toSend =
			chatroom: $scope.chatroom.name
			sender: $scope.user.name
			message: $scope.user.message
		Socket.emit "chat message", toSend
		console.log "Sending #{JSON.stringify toSend}"
		$scope.user.message = ""


	#
	# Socket handlers
	#


	# Handle incoming messages
	Socket.on "chat message", (message) ->
		if $scope.chatroom.name != message.for
			console.log "That message is for #{message.for} not this chatroom, #{$scope.chatroom.name}!"
			return

		# We don't want to modify the input
		copy = Object.clone message
		delete copy.for
		# Parse datetime
		copy.datetime = dateStringToDateTimeObject copy.datetime

		console.log "Received message object: #{JSON.stringify copy}"
		$scope.chatroom.messages.push copy

	# Handle new users in the chatroom
	Socket.on "chatroom users", (users)->
		console.log "Seting userlist"
		console.log users
		$scope.chatroom.users = users

	Socket.on "user disconnect", (user)->
		i = $scope.chatroom.users.indexOf user
		$scope.chatroom.users.splice i, 1

	Socket.on "change name", (event)->
		if isUserInChatroom(event.oldName)
			i = $scope.chatroom.users.indexOf event.oldName
			$scope.chatroom.users.splice i, 1, event.newName

		# Rename user in all their messages
		$scope.chatroom.messages.filter (message)->
			message.sender == event.oldName
		.forEach (message)->
			message.sender = event.newName



	#
	# Necessary methods to get things running
	#

	console.log "getting chatroom: #{chatroom = $state.params.chatroom}"
	Chatroom.get {chatroom: chatroom}, (data) ->
			$scope.chatroom =  data
			console.log "got chatroom #{chatroom}!"

			# Get a user and join
			if $scope.user.name
				sendJoinChatroom $scope.user.name
			else
				# Mark that we are changing the username
				$scope.user.changing = true

			for message in $scope.chatroom.messages
				message.datetime = dateStringToDateTimeObject message.datetime

			document.title = "Chatrooms/#{data.name}"

		,(httpResponse)->
			console.error "Couldn't retrieve: #{chatroom}"


chatroomControllers.controller( "ChatroomController", ChatroomController,
	["Chatroom", "$state", "Socket", "$cookies"])
