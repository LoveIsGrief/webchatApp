request = require "request"
module.exports = (grunt) ->

	# show elapsed time at the end
	require("time-grunt") grunt

	# load all grunt tasks
	require("load-grunt-tasks") grunt
	reloadPort = 35729
	files = undefined
	grunt.initConfig
		pkg: grunt.file.readJSON("package.json")
		coffee:
			compile:
				options:
					bare: true

				files: [
					expand: true
					cwd: "public/js"
					src: ["**/*.coffee"]
					dest: "public/js"
					ext: ".js"
				]

		jade:
			compile:
				options:
					data:
						debug: false

				files: [
					expand: true
					cwd: "public/partials"
					src: ["**/*.jade"]
					dest: "public/partials"
					ext: ".html"
				]

		less:
			compile:
				files: [
					expand: true
					cwd: "public/css"
					src: ["**/*.less"]
					dest: "public/css"
					ext: ".css"
				]

		develop:
			production:
				file: "app.js"
				env:
					NODE_ENV: "production"

			dev:
				file: "app.js"
				env:
					NODE_ENV: "development"

			test:
				file: "app.js"
				env:
					NODE_ENV: "test"

		protractor:
			options:
				configFile: "test/protractor.conf.coffee"

			watching:
				options:
					keepAlive:true
			test: {}

		protractor_webdriver:
			all:
				options:
					keepAlive: true

		watch:
			options:
				nospawn: true
				livereload: reloadPort

			test:
				files: [

					"**/*.coffee"
					"**/*.less"
					"**/*.jade"
				]

				tasks: [
					"compile"
					"develop:test"
					"protractor:watching"
					"delayed-livereload"
				]

			dev:
				files: [
					"<%= watch.test.files %>"
				]
				tasks: [
					"compile"
					"develop:dev"
					"delayed-livereload"
				]
				options:
					livereload: reloadPort

	grunt.config.requires "watch.test.files"
	files = grunt.config("watch.test.files")
	files = grunt.file.expand(files)
	grunt.registerTask "delayed-livereload", "Live reload after the node server has restarted.", ->
		done = @async()
		setTimeout (->
			request.get "http://localhost:" + reloadPort + "/changed?files=" + files.join(","), (err, res) ->
				reloaded = not err and res.statusCode is 200
				if reloaded
					grunt.log.ok "Delayed live reload successful."
				else
					grunt.log.error "Unable to make a delayed live reload."
				done reloaded

		), 500

	grunt.registerTask "default", [
		"compile"
		"dev-test"
	]

	# dev-test runs the tests on a dev server (useful for the watch task)
	grunt.registerTask "dev-test", [
		"protractor_webdriver"
		"develop:dev"
		"protractor:test"
	]
	grunt.registerTask "test", [
		"compile"
		"protractor_webdriver"
		"develop:test"
		"protractor:watching"
		"watch:test"
	]
	grunt.registerTask "compile", [
		"coffee"
		"jade"
		"less"
	]
	grunt.loadNpmTasks "grunt-contrib-coffee"
	grunt.loadNpmTasks "grunt-contrib-jade"
	grunt.loadNpmTasks "grunt-contrib-less"
	grunt.loadNpmTasks "grunt-protractor-runner"
	grunt.loadNpmTasks "grunt-protractor-webdriver"
