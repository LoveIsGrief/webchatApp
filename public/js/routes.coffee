@webChatApp.config ($stateProvider, $urlRouterProvider)->

	$urlRouterProvider.otherwise "/"

	$stateProvider
		.state ("chatrooms"), {
			url: "/"
			abstract: true
			template: "<ui-view/>"
		}
		.state ("chatrooms.index"), {
			url: ""
			templateUrl: "/partials/chatrooms/index.html"
			controller: "ChatroomListController"
		}
		.state ("chatrooms.show"), {
			url: ":chatroom"
			templateUrl: "/partials/chatrooms/show.html"
			controller: "ChatroomController"
		}
