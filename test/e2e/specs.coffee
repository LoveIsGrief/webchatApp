
describe "webChatApp", ->

	it "should have a root with a list of chatrooms" , ->
		browser.get "/"

		expect(browser.getTitle()).toEqual "Chatrooms"