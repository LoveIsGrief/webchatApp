module.exports = (config)->
	config.set

		basePath : "../",

		files : [
			"public/components/angular/angular.js",
			"public/components/angular-ui-router/release/angular-ui-router.js",
			"public/components/angular-resource/angular-resource.js",
			"public/components/angular-sanitize/angular-sanitize.js",
			"public/components/angular-mocks/angular-mocks.js",
			"public/js/**/*.coffee",
			"test/unit/**/*.coffee"
		]

		autoWatch : true

		# logLevel: config.DEBUG

		frameworks: ["jasmine"]

		browsers : ["Firefox", "Chrome", "Opera"]

		preprocessors:
			"**/*.coffee": ["coffee"]

		plugins : [
					"karma-firefox-launcher"
					"karma-chrome-launcher"
					"karma-opera-launcher"
					"karma-jasmine"
					"karma-coffee-preprocessor"
				]

		junitReporter :
			outputFile: "test_out/unit.xml"
			suite: "unit"
