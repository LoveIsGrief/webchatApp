chatroomControllers = angular.module "chatroomControllers", []

# Used to control a list of chatrooms
ChatroomListController = ($scope, Chatroom) ->

	console.log "Created ChatroomListController"

	$scope.chatrooms = []

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
	$scope.message = "Type a message here"
	$scope.username = "herp"

	console.log "getting chatroom: #{chatroom = $state.params.chatroom}"
	Chatroom.get {chatroom: chatroom}, (data) ->
			$scope.chatroom =  data
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
			sender: $scope.username
			message: $scope.message
		$scope.message = ""



chatroomControllers.controller( "ChatroomController", ChatroomController,
	["Chatroom", "$state", "Socket"])
