socketServices = angular.module "socketServices", []

Socket = ($location, $rootScope)->
	# Init in different namespace
	# for each different chatroom
	# socket = io($location.url())
	socket = io()

	console.log "socket.io initialized"

	# Replace socket.on with angularized on
	socket["__on"] = socket.on
	socket.on = (trigger, func)->

		# call original
		socket["__on"] trigger, (message)->
			# Angularize
			$rootScope.$apply ->
				# Call with args
				func.call @, message


	socket

socketServices.factory "Socket", [
 "$location", "$rootScope", Socket
]