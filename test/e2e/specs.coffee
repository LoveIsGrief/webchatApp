env = process.env.NODE_ENV || "test"
rek = sys = require 'rekuire'
db = rek "dbs/#{env}"
dbs = Object.keys db


describe "webChatApp", ->

	beforeEach ->
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

	it "should have a root with a list of chatrooms" , ->
		browser.get "/"

		expect(browser.getTitle()).toEqual "Chatrooms"

		chatrooms = element.all By.repeater('chatroom in chatrooms')

		expect( chatrooms.count() ).toBeGreaterThan 0
		expect( chatrooms.count() ).toBe 2
