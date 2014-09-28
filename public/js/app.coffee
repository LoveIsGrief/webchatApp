webChatApp = angular.module "webChatApp", [
		"ngSanitize"
		"ui.router"
		"chatroomControllers"
		"chatroomResources"
	]

webChatApp.config ($locationProvider) ->
	$locationProvider.html5Mode true