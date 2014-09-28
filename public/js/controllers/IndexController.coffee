IndexController = ($scope)->

	$scope.chatrooms = [ "offtopic", "herp", "derp"]
	console.log "IndexController"

@webChatApp.controller "IndexController", IndexController, []