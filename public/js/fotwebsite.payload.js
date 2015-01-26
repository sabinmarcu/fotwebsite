
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
}).call(this)({"data/views/pages/Partners": function(exports, require, module) {module.exports = "<h1>To be determined!</h1>"}, "data/views/pages/Projects": function(exports, require, module) {module.exports = "<h1>To be determined!</h1>"}, "data/views/pages/about.brief": function(exports, require, module) {module.exports = "<p>Fish On Toast was set up in 2002 and since then has been working to nurture and develop the next generation of entrepreneurs by encouraging a culture of innovation, inspiration and collaboration. We pride ourselves on having one of the most ambitious, motivated and creative people as our members.</p>"}, "data/views/pages/about.content": function(exports, require, module) {module.exports = "<p>Fish On Toast was set up in 2002 and since then has been working to nurture and develop the next generation of entrepreneurs by encouraging a culture of innovation, inspiration and collaboration. We pride ourselves on having one of the most ambitious, motivated and creative people as our members.</p>\n\n<p>We delivers speaker events, workshops and competitions to inspire, develop and support entrepreneurs within the university.  Whether you want to start a business, learn more about entrepreneurship or even get hands-on experience with real-world business, this is the place for you. To find out more about our events, get in touch via <a href=\"www.facebook.com/fishontoast\">facebook</a> or <a href=\"https://twitter.com/FishOnToast\">twitter</a>.</p>\n\n<p>We pride ourselves on having one of the most ambitious, motivated and creative groups of people as our members. You might not have thought about what you want to do after graduation but that doesn't matter. If you're simply looking for something fun to fill your Thursday evenings or you want to start a business next week, Fish on Toast is for you. We're all about getting excited by each other's, and our incredible visiting speakers, enthusiasm and drive. We also run our own businesses, and enter competitions. We are the most inspiring club that you can join at university.</p>\n\n<p>With over 200 paying members, Fish on Toast is one of most popular student societies at The University of Southampton, if you want to develop your ambition, like to go to great events or are simply looking to meet some awesome people - Fish on Toast is the best place to do so in Southampton! </p>\n\n<p>Together we can learn the secrets for business success meet some awesome people and change the world!!\nBenefit of getting involved...</p>\n\n<p>Getting involved with Fish on Toast will greatly enhance your University experience and give you the opportunity to:</p>\n\n<ul>\n<li>Explore entrepreneurship as a career or business opportunity</li>\n<li>Hear from entrepreneurs, who have successfully run their own businesses</li>\n<li>Meet like-minded people, build a network and discuss ideas</li>\n<li>Gain support for your student start-up</li>\n<li>Develop hands-on business skills</li>\n<li>Get access to great local and national enterprise competitions</li>\n<li>Graduate passport points</li>\n<li>Free Pizza!</li>\n</ul>"}, "data/views/pages/membership.brief": function(exports, require, module) {module.exports = "<p>All Fish on Toast members will have exclusive access to exciting events that are ongoing throughout term-time semesters on Thursday evenings. Events are often led by famous speakers that have been successful in starting and growing their own company. Events may also include business challenges for members to demonstrate their creativity and business acumen, and to further develop their skills. </p>"}, "data/views/pages/membership.content": function(exports, require, module) {module.exports = "<p>All Fish on Toast members will have exclusive access to exciting events that are ongoing throughout term-time semesters on Thursday evenings. Events are often led by famous speakers that have been successful in starting and growing their own company. Events may also include business challenges for members to demonstrate their creativity and business acumen, and to further develop their skills. </p>\n\n<p>After paying £5 for a membership, each registered member will receive the following:</p>\n\n<ul>\n<li>Opportunities to attend external events the society has links to</li>\n<li>Networking sessions with employers and representatives from large companies</li>\n<li>First entry into competitions with prizes ranging from ice cream to iPads</li>\n<li>Free complementary pizza after the event</li>\n<li>Free subscription of a monthly newsletter including details about the events </li>\n<li>Graduate passport points that can be collected after every event</li>\n</ul>"}});
