webChatApp = angular.module "webChatApp", [
		"ngSanitize"
		"ui.router"
		"chatroomControllers"
		"chatroomResources"
		"socketServices"
	]

webChatApp.config ($locationProvider) ->
	$locationProvider.html5Mode true