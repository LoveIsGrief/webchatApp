chatroomControllers = angular.module "chatroomControllers", []

# Used to control a list of chatrooms
ChatroomListController = ($scope, Chatroom) ->

	console.log "Created ChatroomListController"

	$scope.chatrooms = []

	# async call that returns a list of chatrooms from the backend
	Chatroom.query {}, (data) ->
		$scope.chatrooms = data
		console.log "success"


chatroomControllers.controller( "ChatroomListController", ChatroomListController,
	["Chatroom"])


# Used to control 1 chatroom
ChatroomController = ($scope, Chatroom, $state) ->

	console.log "Created ChatroomController"
	$scope.chatroom = { name: "", messages: []}

	console.log "getting chatroom: #{chatroom = $state.params.chatroom}"
	Chatroom.query {chatroom: chatroom}, (data) ->
			$scope.chatroom =  data
			console.log "success!"
		,(httpResponse)->
			console.error "Couldn't retrieve: #{chatroom}"


chatroomControllers.controller( "ChatroomController", ChatroomController,
	["Chatroom", "$state"])
