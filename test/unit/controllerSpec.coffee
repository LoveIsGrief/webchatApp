
describe 'Webchat controllers', ->

	chatroom = "offtopic"
	chatrooms = "offtopic":
					"name": chatroom
					"messages": [
						{
							"datetime": "2014-09-27T14:51:06.048Z",
							"sender": "herp",
							"content": "<h1>ROFL!</h1><script>alert(\"hacked!!!!\")</script>"
						}
						]

	beforeEach ->
		module("ngSanitize")
		module("ui.router")
		module("chatroomControllers")
		module("chatroomResources")

		module("webChatApp")

	beforeEach ->
		@addMatchers
			toIntersectWith: ->
				compare: (actual,expected)->
					ret = true
					for item of expected
						unless actual[item]
							ret = false
							break

					pass: ret

	describe "ChatroomController", ->

		scope = {}
		$httpBackend = {}
		control = {}


		# Handle a call to the webserver to GET a chatroom
		beforeEach inject (_$httpBackend_, $rootScope, $controller, Chatroom) ->
			$httpBackend = _$httpBackend_;
			$httpBackend.expectGET('/api/chatrooms/offtopic').
			respond chatrooms[chatroom]


			scope = $rootScope.$new()
			$state = params: chatroom: chatroom
			control = $controller "ChatroomController",
				$scope: scope
				Chatroom: Chatroom
				$state: $state

		afterEach ->
			$httpBackend.verifyNoOutstandingExpectation()
			$httpBackend.verifyNoOutstandingRequest()

		it "should retrieve a chatroom with one message", () ->
			$httpBackend.flush()
			expect(scope.chatroom.messages.length).toBe 1

	describe "ChatroomListController", ->

		scope = {}
		$httpBackend = {}
		control = {}

		# Handle a call to the webserver to GET a list of all chatrooms
		beforeEach inject (_$httpBackend_, $rootScope, $controller, Chatroom) ->
			$httpBackend = _$httpBackend_;
			console.log "created httpBackend"
			$httpBackend.expectGET('/api/chatrooms').
			respond chatrooms

			scope = $rootScope.$new()
			control = $controller "ChatroomListController",
				$scope: scope
				Chatroom: Chatroom

		afterEach ->
			$httpBackend.verifyNoOutstandingExpectation()
			$httpBackend.verifyNoOutstandingRequest()

		it "should retrieve chatrooms", () ->
			$httpBackend.flush()

			# Keys are compared because scope.chatrooms is a Response object
			expect(Object.keys(scope.chatrooms)).toIntersectWith Object.keys(chatrooms)