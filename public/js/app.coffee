webChatApp = angular.module "webChatApp", [
		"ngSanitize"
		"ui.router"
		"ui.bootstrap"
		"chatroomControllers"
		"chatroomResources"
		"socketServices"
		"luegg.directives" # for scroll-glue (autoscrolling)
	]

webChatApp.config ($locationProvider) ->
	$locationProvider.html5Mode true