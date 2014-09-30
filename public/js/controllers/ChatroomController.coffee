chatroomControllers = angular.module "chatroomControllers", []

# Used to control a list of chatrooms
ChatroomListController = ($scope, Chatroom) ->

	console.log "Created ChatroomListController"

	$scope.chatrooms = []
	$scope.chatroomFilter = ""

	# async call that returns a list of chatrooms from the backend
	Chatroom.query {}, (data) ->
		$scope.chatrooms = data
		console.log "got chatrooms"


chatroomControllers.controller( "ChatroomListController", ChatroomListController,
	["Chatroom"])


# Used to control 1 chatroom
ChatroomController = ($scope, Chatroom, $state, Socket) ->

	console.log "Created ChatroomController"
	$scope.chatroom = { name: "", messages: []}

	# Need an object to pass through ng-if and similar scopes
	$scope.user = {
		name: "herp"
		tempName: ""
		changing: false
		validation: ""
		message: "Type a message here"
	}

	$scope.toggleUsernameChanging = ->
		console.log "Toggle user.changing"
		$scope.user.tempName = $scope.user.name
		$scope.user.changing = ! $scope.user.changing

	$scope.validateNewUsername = ->
		console.log "old username: #{$scope.user.name}"
		console.log "new username: #{$scope.user.tempName}"
		$scope.user.validation = "has-success"
		true #TODO implement validation

	$scope.changeUsername = ->
		return if not $scope.validateNewUsername

		console.log "Setting username to #{$scope.user.tempName}"
		$scope.user.name = "#{$scope.user.tempName}"
		$scope.toggleUsernameChanging()



	console.log "getting chatroom: #{chatroom = $state.params.chatroom}"
	Chatroom.get {chatroom: chatroom}, (data) ->
			$scope.chatroom =  data
			$scope.chatroom.users = ["herp", "derp", "yomama"]
			Socket.emit "join chatroom", $scope.chatroom.name
			console.log "got chatroom #{chatroom}!"
		,(httpResponse)->
			console.error "Couldn't retrieve: #{chatroom}"


	# Handle incoming messages
	Socket.on "chat message", (message) ->
		return if $scope.chatroom.name != message.for
		delete message.for
		console.log message
		$scope.chatroom.messages.push message

	$scope.sendMessage = ->
		console.log Socket.emit
		Socket.emit "chat message",
			chatroom: $scope.chatroom.name
			sender: $scope.user.name
			message: $scope.user.message
		$scope.user.message = ""



chatroomControllers.controller( "ChatroomController", ChatroomController,
	["Chatroom", "$state", "Socket"])
