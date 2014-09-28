chatroomResources = angular.module "chatroomResources", ["ngResource"]

Chatroom = ($resource)->
	$resource "/api/chatrooms/:chatroom", {},
		update:
			method: "PUT"
		query:
			method: "GET"

chatroomResources.factory "Chatroom", Chatroom