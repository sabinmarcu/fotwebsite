
(function(/*! Stitch !*/) {
	if (!this.require) {
		var modules = {}, cache = {}, require = function(name, root) {
			var path = expand(root, name), module = cache[path], fn;
			if (module) {
				return module.exports;
			} else if (fn = modules[path] || modules[path = expand(path, './index')]) {
				module = {id: path, exports: {}};
				try {
					cache[path] = module;
					fn(module.exports, function(name) {
						return require(name, dirname(path));
					}, module);
					return module.exports;
				} catch (err) {
					delete cache[path];
					throw err;
				}
			} else {
				throw 'module \'' + name + '\' not found';
			}
		}, expand = function(root, name) {
			var results = [], parts, part;
			if (/^\.\.?(\/|$)/.test(name)) {
				parts = [root, name].join('/').split('/');
			} else {
				parts = name.split('/');
			}
			for (var i = 0, length = parts.length; i < length; i++) {
				part = parts[i];
				if (part == '..') {
					results.pop();
				} else if (part != '.' && part != '') {
					results.push(part);
				}
			}
			return results.join('/');
		}, dirname = function(path) {
			return path.split('/').slice(0, -1).join('/');
		};
		this.require = function(name) {
			return require(name, '');
		}
		this.require.define = function(bundle) {
			for (var key in bundle)
				modules[key] = bundle[key];
		};
	}
	return this.require.define;
}).call(this)({"data/views/pages/Partners": function(exports, require, module) {module.exports = "<h1>To be determined!</h1>"}, "data/views/pages/Projects": function(exports, require, module) {module.exports = "<h1>To be determined!</h1>"}, "data/views/pages/about.brief": function(exports, require, module) {module.exports = "<p>Brief for About</p>"}, "data/views/pages/about.content": function(exports, require, module) {module.exports = "<p>Brief for Content</p>"}, "data/views/pages/membership.brief": function(exports, require, module) {module.exports = "<p>Membership Brief</p>"}, "data/views/pages/membership.content": function(exports, require, module) {module.exports = "<p>Membership Content</p>"}});
