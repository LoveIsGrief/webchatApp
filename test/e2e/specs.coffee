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

		it "should display the offtopic chatroom" , ->

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

