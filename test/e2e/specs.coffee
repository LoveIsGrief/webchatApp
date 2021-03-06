env = process.env.NODE_ENV || "test"
rek = sys = require 'rekuire'
db = rek "dbs/#{env}"
dbs = Object.keys db


describe "webChatApp", ->

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

		# Make sure we start clean for each test suite
		browser.manage().deleteAllCookies();


	describe 'homepage', ->

		beforeEach ->
			browser.get "/"

		it "should have a root with a list of chatrooms" , ->

			expect(browser.getTitle()).toEqual "Chatrooms"

			chatrooms = element.all By.repeater('chatroom in chatrooms')

			expect( chatrooms.count() ).toBeGreaterThan 0
			expect( chatrooms.count() ).toBe 2

			# Check if the chatrooms in the db are on the page
			expect( chatrooms.getText()).toIntersectWith dbs

	describe 'offtopic chatroom', ->

		beforeEach ->
			browser.get "/offtopic"

		it "should display the offtopic chatroom messages" , ->

			expect(browser.getTitle()).toEqual "Chatrooms/offtopic"

			messages = By.repeater("message in chatroom.messages")
			messageEls = element.all messages
			expect( messageEls.count()).toBeGreaterThan 0

			messageContentEls = element.all messages.column "message.message"
			expect( messageContentEls.count()).toBeGreaterThan 0
			expect( messageContentEls.first().getText()).toEqual "ROFL!"

			messageUserEls = element.all messages.column "message.sender"
			expect( messageUserEls.count()).toBeGreaterThan 0
			expect( messageUserEls.first().getText()).toEqual "herp"

			messageTimeEls = element.all messages.column "message.datetime"
			expect( messageTimeEls.count()).toBeGreaterThan 0
			expect( messageTimeEls.first().getText()).toMatch /\d{2}:\d{2}:\d{2}.\d+/

		it "should make the user pick a name for first connection" , ->

			expect(browser.getTitle()).toEqual "Chatrooms/offtopic"

			# No users in the chatroom
			users = element.all By.repeater("user in chatroom.users")
			expect( users.count()).toBe 0

			# Pick a name
			username = "tester"
			nameEntry = element By.model "user.tempName"
			nameEntry.sendKeys username
			nameEntry.submit()

			# Display show name
			nameDisplay = element By.binding "user.name"
			# It will display "<name>:" therefore "toContain"
			expect(nameDisplay.getText()).toContain username

			# No users in the chatroom
			users = element.all By.repeater("user in chatroom.users")
			expect( users.count()).toBe 1

	describe "chatroom switching from offtopic" , ->

		beforeEach ->
			@username = "tester"

			# A shortcut to username creation
			browser.manage().addCookie "username", @username, "/", "localhost"
			browser.get "/offtopic"

		it "should keep username when switching", ->

			nameDisplay = element By.binding "user.name"
			expect(nameDisplay.getText()).toContain @username

			browser.get "/ontopic"

			nameDisplay = element By.binding "user.name"
			expect(nameDisplay.getText()).toContain @username

		it "should be able to send messages in each chatroom", ->

			# Send message and check for presence in /offtopic
			messageEl = element By.model "user.message"
			messageText = "Message in offtopic"
			messageEl.sendKeys messageText
			messageEl.submit()

			# Is message there?
			messages = By.repeater("message in chatroom.messages")
			messageContentEls = element.all messages.column "message.message"
			expect(messageContentEls.last().getText()).toEqual messageText


			# Repeat sending a message in /ontopic
			browser.get "/ontopic"
			messageEl = element By.model "user.message"
			messageText = "Message in ontopic"
			messageEl.sendKeys messageText
			messageEl.submit()

			# Is message there?
			messages = By.repeater("message in chatroom.messages")
			messageContentEls = element.all messages.column "message.message"
			expect(messageContentEls.last().getText()).toEqual messageText

