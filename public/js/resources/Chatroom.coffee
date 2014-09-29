chatroomResources = angular.module "chatroomResources", ["ngResource"]

Chatroom = ($resource)->
	$resource "/api/chatrooms/:chatroom", {},
		update:
			method: "PUT"

chatroomResources.factory "Chatroom", Chatroom