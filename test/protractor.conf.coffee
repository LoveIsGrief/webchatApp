exports.config =
	allScriptsTimeout: 11000
	seleniumAddress: "http://localhost:4444/wd/hub"

	specs: [
		"e2e/*.coffee"
	]

	capabilities:
		"browserName": "firefox"

	baseUrl: "http://localhost:3000/"

	framework: "jasmine"

	jasmineNodeOpts:
		defaultTimeoutInterval: 30000
