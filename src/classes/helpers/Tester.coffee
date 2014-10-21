win = do -> 
	if window.getWindow? then window.getWindow()
	else window

# Prefixes for some things like IndexedDB or RequestAnimationFrame
PREFIXES = ["moz", "webkit", "ms"]

# A list of tests to figure out how to run the app
TESTS =
	"indexeddb": ->
		# Checking whether the base indexedDB exists
		if win.indexedDB then return true
		
		# Else, check if one of the other ones are available
		return true for prefix in PREFIXES when win["#{prefix}IndexedDB"]?
		false
		
	"localstorage": -> chrome?.storage? or win.localStorage? # Only two things to check here : normal API and Chrome local DBStorage

	"chrome.storage": -> chrome? and chrome.storage?
	"webkitNotifications": -> Notification? or webkitNotifications?
	"mozNotifications": -> Notification? or mozNotification?
	"mac": -> (navigator.userAgent.indexOf "Macintosh") >= 0
	"ios": -> /(iPad|iPhone|iPad)/.test navigator.userAgent
	"requestAnimationFrame": -> 
		# Checking whether the base rAF exists
		if win.requestAnimationFrame then return true

		# Else, check if one of the other ones is available
		return true for prefix in PREFIXES when win["#{prefix}RequestAnimationFrame"]
		return false
	"audioContext": -> win.AudioContext? or win.webkitAudioContext?
	"getUserMedia": -> navigator.getUserMedia? or navigator.webkitGetUserMedia? or navigator.mozGetUserMedia? or navigator.oGetUserMedia? or navigator.msGetUserMedia?
	"mobile": -> /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)

# A list of functions that normalize some stuff relating to databases and stuff
NORMIALIZES =
	"indexeddb": -> unless win.indexedDB
		# These are the props that belong to indexedDB
		PROPS = ["IDBCursor", "IDBCursorWithValue", "IDBTransaction", "IDBDatabase", "IDBIndex", "IDBKeyRange", "IDBFactory", "IDBObjectStore", "IDBOpenDBRequest", "IDBRequest", "IDBVersionChangeEvent"]

		# Getting the right one and normalizing it
		for prop in PROPS
			win[prop] = win["#{prefix}#{prop}"] for prefix in PREFIXES when win["#{prefix}IndexedDB"]?

		# And finally indexedDB itself is normalized
		win.indexedDB = win["#{prefix}IndexedDB"] for prefix in PREFIXES when win["#{prefix}IndexedDB"]?

	"localstorage": ->
		# If running the app in a chrome packaged app, use chrome local localstorage
		win.LocalStorage = {}
		if chrome? and chrome.storage?
			win.LocalStorage.set = (key, value) -> chrome.storage.local.set key: value
			win.LocalStorage.get = (args...) -> chrome.storage.local.get.apply chrome.storage.local, args
			win.LocalStorage.remove = chrome.storage.local.remove
		# Else run the regular localstorage with a slightly different API
		else
			win.LocalStorage.set = (key, value) -> localStorage.setItem key, value
			win.LocalStorage.get = (item, callback) -> res = {}; res[item] = win.localStorage.getItem item; callback res
			win.LocalStorage.remove = (item) -> win.localStorage.removeItem item

	"requestAnimationFrame" : -> 
		if not win.requestAnimationFrame?
			return win.requestAnimationFrame = win["#{prefix}RequestAnimationFrame"] for prefix in PREFIXES when win["#{prefix}RequestAnimationFrame"]?

	"mozNotifications": -> if not win.Notification? then win.Notification = win.mozNotification or win.webkitNotification

	"audioContext": -> return win.audioContext = win.AudioContext or win.webkitAudioContext
	"getUserMedia": -> 
		if not navigator.getUserMedia?
			 return navigator.getUserMedia = navigator.webkitGetUserMedia or navigator.mozGetUserMedia or navigator.oGetUserMedia or navigator.msGetUserMedia

# Finally wrapping them up in an object that runs the tests, runs the normalizes and makes the test results available
# Also, if a test was unsuccesful then the normalize function associated never runs
class Tester extends window.IS.Object
	constructor: (cb) -> do @tests; do @normalize; window.Tester ?= @; if cb? then do cb
	tests: -> @[name] = do test for name, test of TESTS
	normalize: -> do normalize for name, normalize of NORMIALIZES

module.exports = Tester
