
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
}).call(this)({"data/jsons/countries": function(exports, require, module) {if (!window.JSONImport) window.JSONImport = {};
var item = JSON.parse("[ \n  {\"name\": \"Afghanistan\", \"code\": \"AF\"}, \n  {\"name\": \"Åland Islands\", \"code\": \"AX\"}, \n  {\"name\": \"Albania\", \"code\": \"AL\"}, \n  {\"name\": \"Algeria\", \"code\": \"DZ\"}, \n  {\"name\": \"American Samoa\", \"code\": \"AS\"}, \n  {\"name\": \"AndorrA\", \"code\": \"AD\"}, \n  {\"name\": \"Angola\", \"code\": \"AO\"}, \n  {\"name\": \"Anguilla\", \"code\": \"AI\"}, \n  {\"name\": \"Antarctica\", \"code\": \"AQ\"}, \n  {\"name\": \"Antigua and Barbuda\", \"code\": \"AG\"}, \n  {\"name\": \"Argentina\", \"code\": \"AR\"}, \n  {\"name\": \"Armenia\", \"code\": \"AM\"}, \n  {\"name\": \"Aruba\", \"code\": \"AW\"}, \n  {\"name\": \"Australia\", \"code\": \"AU\"}, \n  {\"name\": \"Austria\", \"code\": \"AT\"}, \n  {\"name\": \"Azerbaijan\", \"code\": \"AZ\"}, \n  {\"name\": \"Bahamas\", \"code\": \"BS\"}, \n  {\"name\": \"Bahrain\", \"code\": \"BH\"}, \n  {\"name\": \"Bangladesh\", \"code\": \"BD\"}, \n  {\"name\": \"Barbados\", \"code\": \"BB\"}, \n  {\"name\": \"Belarus\", \"code\": \"BY\"}, \n  {\"name\": \"Belgium\", \"code\": \"BE\"}, \n  {\"name\": \"Belize\", \"code\": \"BZ\"}, \n  {\"name\": \"Benin\", \"code\": \"BJ\"}, \n  {\"name\": \"Bermuda\", \"code\": \"BM\"}, \n  {\"name\": \"Bhutan\", \"code\": \"BT\"}, \n  {\"name\": \"Bolivia\", \"code\": \"BO\"}, \n  {\"name\": \"Bosnia and Herzegovina\", \"code\": \"BA\"}, \n  {\"name\": \"Botswana\", \"code\": \"BW\"}, \n  {\"name\": \"Bouvet Island\", \"code\": \"BV\"}, \n  {\"name\": \"Brazil\", \"code\": \"BR\"}, \n  {\"name\": \"British Indian Ocean Territory\", \"code\": \"IO\"}, \n  {\"name\": \"Brunei Darussalam\", \"code\": \"BN\"}, \n  {\"name\": \"Bulgaria\", \"code\": \"BG\"}, \n  {\"name\": \"Burkina Faso\", \"code\": \"BF\"}, \n  {\"name\": \"Burundi\", \"code\": \"BI\"}, \n  {\"name\": \"Cambodia\", \"code\": \"KH\"}, \n  {\"name\": \"Cameroon\", \"code\": \"CM\"}, \n  {\"name\": \"Canada\", \"code\": \"CA\"}, \n  {\"name\": \"Cape Verde\", \"code\": \"CV\"}, \n  {\"name\": \"Cayman Islands\", \"code\": \"KY\"}, \n  {\"name\": \"Central African Republic\", \"code\": \"CF\"}, \n  {\"name\": \"Chad\", \"code\": \"TD\"}, \n  {\"name\": \"Chile\", \"code\": \"CL\"}, \n  {\"name\": \"China\", \"code\": \"CN\"}, \n  {\"name\": \"Christmas Island\", \"code\": \"CX\"}, \n  {\"name\": \"Cocos (Keeling) Islands\", \"code\": \"CC\"}, \n  {\"name\": \"Colombia\", \"code\": \"CO\"}, \n  {\"name\": \"Comoros\", \"code\": \"KM\"}, \n  {\"name\": \"Congo\", \"code\": \"CG\"}, \n  {\"name\": \"Congo, The Democratic Republic of the\", \"code\": \"CD\"}, \n  {\"name\": \"Cook Islands\", \"code\": \"CK\"}, \n  {\"name\": \"Costa Rica\", \"code\": \"CR\"}, \n  {\"name\": \"Cote D`Ivoire\", \"code\": \"CI\"}, \n  {\"name\": \"Croatia\", \"code\": \"HR\"}, \n  {\"name\": \"Cuba\", \"code\": \"CU\"}, \n  {\"name\": \"Cyprus\", \"code\": \"CY\"}, \n  {\"name\": \"Czech Republic\", \"code\": \"CZ\"}, \n  {\"name\": \"Denmark\", \"code\": \"DK\"}, \n  {\"name\": \"Djibouti\", \"code\": \"DJ\"}, \n  {\"name\": \"Dominica\", \"code\": \"DM\"}, \n  {\"name\": \"Dominican Republic\", \"code\": \"DO\"}, \n  {\"name\": \"Ecuador\", \"code\": \"EC\"}, \n  {\"name\": \"Egypt\", \"code\": \"EG\"}, \n  {\"name\": \"El Salvador\", \"code\": \"SV\"}, \n  {\"name\": \"Equatorial Guinea\", \"code\": \"GQ\"}, \n  {\"name\": \"Eritrea\", \"code\": \"ER\"}, \n  {\"name\": \"Estonia\", \"code\": \"EE\"}, \n  {\"name\": \"Ethiopia\", \"code\": \"ET\"}, \n  {\"name\": \"Falkland Islands (Malvinas)\", \"code\": \"FK\"}, \n  {\"name\": \"Faroe Islands\", \"code\": \"FO\"}, \n  {\"name\": \"Fiji\", \"code\": \"FJ\"}, \n  {\"name\": \"Finland\", \"code\": \"FI\"}, \n  {\"name\": \"France\", \"code\": \"FR\"}, \n  {\"name\": \"French Guiana\", \"code\": \"GF\"}, \n  {\"name\": \"French Polynesia\", \"code\": \"PF\"}, \n  {\"name\": \"French Southern Territories\", \"code\": \"TF\"}, \n  {\"name\": \"Gabon\", \"code\": \"GA\"}, \n  {\"name\": \"Gambia\", \"code\": \"GM\"}, \n  {\"name\": \"Georgia\", \"code\": \"GE\"}, \n  {\"name\": \"Germany\", \"code\": \"DE\"}, \n  {\"name\": \"Ghana\", \"code\": \"GH\"}, \n  {\"name\": \"Gibraltar\", \"code\": \"GI\"}, \n  {\"name\": \"Greece\", \"code\": \"GR\"}, \n  {\"name\": \"Greenland\", \"code\": \"GL\"}, \n  {\"name\": \"Grenada\", \"code\": \"GD\"}, \n  {\"name\": \"Guadeloupe\", \"code\": \"GP\"}, \n  {\"name\": \"Guam\", \"code\": \"GU\"}, \n  {\"name\": \"Guatemala\", \"code\": \"GT\"}, \n  {\"name\": \"Guernsey\", \"code\": \"GG\"}, \n  {\"name\": \"Guinea\", \"code\": \"GN\"}, \n  {\"name\": \"Guinea-Bissau\", \"code\": \"GW\"}, \n  {\"name\": \"Guyana\", \"code\": \"GY\"}, \n  {\"name\": \"Haiti\", \"code\": \"HT\"}, \n  {\"name\": \"Heard Island and Mcdonald Islands\", \"code\": \"HM\"}, \n  {\"name\": \"Holy See (Vatican City State)\", \"code\": \"VA\"}, \n  {\"name\": \"Honduras\", \"code\": \"HN\"}, \n  {\"name\": \"Hong Kong\", \"code\": \"HK\"}, \n  {\"name\": \"Hungary\", \"code\": \"HU\"}, \n  {\"name\": \"Iceland\", \"code\": \"IS\"}, \n  {\"name\": \"India\", \"code\": \"IN\"}, \n  {\"name\": \"Indonesia\", \"code\": \"ID\"}, \n  {\"name\": \"Iran, Islamic Republic Of\", \"code\": \"IR\"}, \n  {\"name\": \"Iraq\", \"code\": \"IQ\"}, \n  {\"name\": \"Ireland\", \"code\": \"IE\"}, \n  {\"name\": \"Isle of Man\", \"code\": \"IM\"}, \n  {\"name\": \"Israel\", \"code\": \"IL\"}, \n  {\"name\": \"Italy\", \"code\": \"IT\"}, \n  {\"name\": \"Jamaica\", \"code\": \"JM\"}, \n  {\"name\": \"Japan\", \"code\": \"JP\"}, \n  {\"name\": \"Jersey\", \"code\": \"JE\"}, \n  {\"name\": \"Jordan\", \"code\": \"JO\"}, \n  {\"name\": \"Kazakhstan\", \"code\": \"KZ\"}, \n  {\"name\": \"Kenya\", \"code\": \"KE\"}, \n  {\"name\": \"Kiribati\", \"code\": \"KI\"}, \n  {\"name\": \"Korea, Democratic People`S Republic of\", \"code\": \"KP\"}, \n  {\"name\": \"Korea, Republic of\", \"code\": \"KR\"}, \n  {\"name\": \"Kuwait\", \"code\": \"KW\"}, \n  {\"name\": \"Kyrgyzstan\", \"code\": \"KG\"}, \n  {\"name\": \"Lao People`S Democratic Republic\", \"code\": \"LA\"}, \n  {\"name\": \"Latvia\", \"code\": \"LV\"}, \n  {\"name\": \"Lebanon\", \"code\": \"LB\"}, \n  {\"name\": \"Lesotho\", \"code\": \"LS\"}, \n  {\"name\": \"Liberia\", \"code\": \"LR\"}, \n  {\"name\": \"Libyan Arab Jamahiriya\", \"code\": \"LY\"}, \n  {\"name\": \"Liechtenstein\", \"code\": \"LI\"}, \n  {\"name\": \"Lithuania\", \"code\": \"LT\"}, \n  {\"name\": \"Luxembourg\", \"code\": \"LU\"}, \n  {\"name\": \"Macao\", \"code\": \"MO\"}, \n  {\"name\": \"Macedonia, The Former Yugoslav Republic of\", \"code\": \"MK\"}, \n  {\"name\": \"Madagascar\", \"code\": \"MG\"}, \n  {\"name\": \"Malawi\", \"code\": \"MW\"}, \n  {\"name\": \"Malaysia\", \"code\": \"MY\"}, \n  {\"name\": \"Maldives\", \"code\": \"MV\"}, \n  {\"name\": \"Mali\", \"code\": \"ML\"}, \n  {\"name\": \"Malta\", \"code\": \"MT\"}, \n  {\"name\": \"Marshall Islands\", \"code\": \"MH\"}, \n  {\"name\": \"Martinique\", \"code\": \"MQ\"}, \n  {\"name\": \"Mauritania\", \"code\": \"MR\"}, \n  {\"name\": \"Mauritius\", \"code\": \"MU\"}, \n  {\"name\": \"Mayotte\", \"code\": \"YT\"}, \n  {\"name\": \"Mexico\", \"code\": \"MX\"}, \n  {\"name\": \"Micronesia, Federated States of\", \"code\": \"FM\"}, \n  {\"name\": \"Moldova, Republic of\", \"code\": \"MD\"}, \n  {\"name\": \"Monaco\", \"code\": \"MC\"}, \n  {\"name\": \"Mongolia\", \"code\": \"MN\"}, \n  {\"name\": \"Montserrat\", \"code\": \"MS\"}, \n  {\"name\": \"Morocco\", \"code\": \"MA\"}, \n  {\"name\": \"Mozambique\", \"code\": \"MZ\"}, \n  {\"name\": \"Myanmar\", \"code\": \"MM\"}, \n  {\"name\": \"Namibia\", \"code\": \"NA\"}, \n  {\"name\": \"Nauru\", \"code\": \"NR\"}, \n  {\"name\": \"Nepal\", \"code\": \"NP\"}, \n  {\"name\": \"Netherlands\", \"code\": \"NL\"}, \n  {\"name\": \"Netherlands Antilles\", \"code\": \"AN\"}, \n  {\"name\": \"New Caledonia\", \"code\": \"NC\"}, \n  {\"name\": \"New Zealand\", \"code\": \"NZ\"}, \n  {\"name\": \"Nicaragua\", \"code\": \"NI\"}, \n  {\"name\": \"Niger\", \"code\": \"NE\"}, \n  {\"name\": \"Nigeria\", \"code\": \"NG\"}, \n  {\"name\": \"Niue\", \"code\": \"NU\"}, \n  {\"name\": \"Norfolk Island\", \"code\": \"NF\"}, \n  {\"name\": \"Northern Mariana Islands\", \"code\": \"MP\"}, \n  {\"name\": \"Norway\", \"code\": \"NO\"}, \n  {\"name\": \"Oman\", \"code\": \"OM\"}, \n  {\"name\": \"Pakistan\", \"code\": \"PK\"}, \n  {\"name\": \"Palau\", \"code\": \"PW\"}, \n  {\"name\": \"Palestinian Territory, Occupied\", \"code\": \"PS\"}, \n  {\"name\": \"Panama\", \"code\": \"PA\"}, \n  {\"name\": \"Papua New Guinea\", \"code\": \"PG\"}, \n  {\"name\": \"Paraguay\", \"code\": \"PY\"}, \n  {\"name\": \"Peru\", \"code\": \"PE\"}, \n  {\"name\": \"Philippines\", \"code\": \"PH\"}, \n  {\"name\": \"Pitcairn\", \"code\": \"PN\"}, \n  {\"name\": \"Poland\", \"code\": \"PL\"}, \n  {\"name\": \"Portugal\", \"code\": \"PT\"}, \n  {\"name\": \"Puerto Rico\", \"code\": \"PR\"}, \n  {\"name\": \"Qatar\", \"code\": \"QA\"}, \n  {\"name\": \"Reunion\", \"code\": \"RE\"}, \n  {\"name\": \"Romania\", \"code\": \"RO\"}, \n  {\"name\": \"Russian Federation\", \"code\": \"RU\"}, \n  {\"name\": \"RWANDA\", \"code\": \"RW\"}, \n  {\"name\": \"Saint Helena\", \"code\": \"SH\"}, \n  {\"name\": \"Saint Kitts and Nevis\", \"code\": \"KN\"}, \n  {\"name\": \"Saint Lucia\", \"code\": \"LC\"}, \n  {\"name\": \"Saint Pierre and Miquelon\", \"code\": \"PM\"}, \n  {\"name\": \"Saint Vincent and the Grenadines\", \"code\": \"VC\"}, \n  {\"name\": \"Samoa\", \"code\": \"WS\"}, \n  {\"name\": \"San Marino\", \"code\": \"SM\"}, \n  {\"name\": \"Sao Tome and Principe\", \"code\": \"ST\"}, \n  {\"name\": \"Saudi Arabia\", \"code\": \"SA\"}, \n  {\"name\": \"Senegal\", \"code\": \"SN\"}, \n  {\"name\": \"Serbia and Montenegro\", \"code\": \"CS\"}, \n  {\"name\": \"Seychelles\", \"code\": \"SC\"}, \n  {\"name\": \"Sierra Leone\", \"code\": \"SL\"}, \n  {\"name\": \"Singapore\", \"code\": \"SG\"}, \n  {\"name\": \"Slovakia\", \"code\": \"SK\"}, \n  {\"name\": \"Slovenia\", \"code\": \"SI\"}, \n  {\"name\": \"Solomon Islands\", \"code\": \"SB\"}, \n  {\"name\": \"Somalia\", \"code\": \"SO\"}, \n  {\"name\": \"South Africa\", \"code\": \"ZA\"}, \n  {\"name\": \"South Georgia and the South Sandwich Islands\", \"code\": \"GS\"}, \n  {\"name\": \"Spain\", \"code\": \"ES\"}, \n  {\"name\": \"Sri Lanka\", \"code\": \"LK\"}, \n  {\"name\": \"Sudan\", \"code\": \"SD\"}, \n  {\"name\": \"Suriname\", \"code\": \"SR\"}, \n  {\"name\": \"Svalbard and Jan Mayen\", \"code\": \"SJ\"}, \n  {\"name\": \"Swaziland\", \"code\": \"SZ\"}, \n  {\"name\": \"Sweden\", \"code\": \"SE\"}, \n  {\"name\": \"Switzerland\", \"code\": \"CH\"}, \n  {\"name\": \"Syrian Arab Republic\", \"code\": \"SY\"}, \n  {\"name\": \"Taiwan, Province of China\", \"code\": \"TW\"}, \n  {\"name\": \"Tajikistan\", \"code\": \"TJ\"}, \n  {\"name\": \"Tanzania, United Republic of\", \"code\": \"TZ\"}, \n  {\"name\": \"Thailand\", \"code\": \"TH\"}, \n  {\"name\": \"Timor-Leste\", \"code\": \"TL\"}, \n  {\"name\": \"Togo\", \"code\": \"TG\"}, \n  {\"name\": \"Tokelau\", \"code\": \"TK\"}, \n  {\"name\": \"Tonga\", \"code\": \"TO\"}, \n  {\"name\": \"Trinidad and Tobago\", \"code\": \"TT\"}, \n  {\"name\": \"Tunisia\", \"code\": \"TN\"}, \n  {\"name\": \"Turkey\", \"code\": \"TR\"}, \n  {\"name\": \"Turkmenistan\", \"code\": \"TM\"}, \n  {\"name\": \"Turks and Caicos Islands\", \"code\": \"TC\"}, \n  {\"name\": \"Tuvalu\", \"code\": \"TV\"}, \n  {\"name\": \"Uganda\", \"code\": \"UG\"}, \n  {\"name\": \"Ukraine\", \"code\": \"UA\"}, \n  {\"name\": \"United Arab Emirates\", \"code\": \"AE\"}, \n  {\"name\": \"United Kingdom\", \"code\": \"GB\"}, \n  {\"name\": \"United States\", \"code\": \"US\"}, \n  {\"name\": \"United States Minor Outlying Islands\", \"code\": \"UM\"}, \n  {\"name\": \"Uruguay\", \"code\": \"UY\"}, \n  {\"name\": \"Uzbekistan\", \"code\": \"UZ\"}, \n  {\"name\": \"Vanuatu\", \"code\": \"VU\"}, \n  {\"name\": \"Venezuela\", \"code\": \"VE\"}, \n  {\"name\": \"Viet Nam\", \"code\": \"VN\"}, \n  {\"name\": \"Virgin Islands, British\", \"code\": \"VG\"}, \n  {\"name\": \"Virgin Islands, U.S.\", \"code\": \"VI\"}, \n  {\"name\": \"Wallis and Futuna\", \"code\": \"WF\"}, \n  {\"name\": \"Western Sahara\", \"code\": \"EH\"}, \n  {\"name\": \"Yemen\", \"code\": \"YE\"}, \n  {\"name\": \"Zambia\", \"code\": \"ZM\"}, \n  {\"name\": \"Zimbabwe\", \"code\": \"ZW\"} \n]", function(key, value) { var v; try { v = eval(value) } catch(e) { v = value } return v;});
return window.JSONImport['countries'] = module.exports = item;}, "data/jsons/events": function(exports, require, module) {if (!window.JSONImport) window.JSONImport = {};
var item = JSON.parse("[\n    {\n        \"image\": \"https://media.licdn.com/media/p/4/005/089/0f3/2b2d7c8.jpg\",\n        \"name\": \"Chris Donnelly\",\n        \"link\": \"https://www.facebook.com/events/1019507614729895/?notif_t=plan_edited\"\n    },\n    {\n        \"name\": \"Business Skills Challenge\",\n        \"image\": \"https://scontent-b-lhr.xx.fbcdn.net/hphotos-xpf1/t31.0-8/1523839_749182608510740_1817503405302824847_o.jpg\"\n    },\n    {\n        \"name\": \"Student Apprentice Final\",\n        \"content\": \"This was awesome!\",\n        \"image\": \"https://fbcdn-sphotos-e-a.akamaihd.net/hphotos-ak-xaf1/v/t1.0-9/10647124_10152645326777961_1547336730203952570_n.jpg?oh=3335db7fb1cf3f58eacabb183d083f65&oe=555C073E&__gda__=1432024970_d52dc06cd9d46d8a52e8d6eb0cdd94fb\",\n        \"link\": \"http://google.com\"\n    },\n    {\n        \"name\": \"Michacel Jackson's Bodyguard\",\n        \"image\": \"https://scontent-b-lhr.xx.fbcdn.net/hphotos-xap1/t31.0-8/1401945_1493124970949440_4251313280182547121_o.jpg\"\n    }\n]", function(key, value) { var v; try { v = eval(value) } catch(e) { v = value } return v;});
return window.JSONImport['events'] = module.exports = item;}, "data/jsons/example_posts": function(exports, require, module) {if (!window.JSONImport) window.JSONImport = {};
var item = JSON.parse("[\n    {\n      \"title\": \"Student Guide\",\n      \"type\": \"Important Information\",\n      \"from\": \"ISR\",\n      \"shortlink\": \"student-guide\",\n      \"href\": \"/student-guide\",\n      \"_id\": \"sg_id\"\n    },\n    {\n      \"title\": \"Membership\",\n      \"type\": \"Members Area\",\n      \"from\": \"ISR\",\n      \"shortlink\": \"members\",\n      \"href\": \"/membership\",\n      \"_id\": \"membership_id\"\n    },\n    {\n      \"title\": \"Membership Benefits\",\n      \"type\": \"Important Information\",\n      \"from\": \"ISR\",\n      \"shortlink\": \"benefits\",\n      \"href\": \"/benefits\",\n      \"_id\": \"membership_benefits_id\"\n    },\n    {\n      \"title\": \"Events\",\n      \"type\": \"\",\n      \"from\": \"ISR\",\n      \"shortlink\": \"events\",\n      \"href\": \"/events\",\n      \"_id\": \"events_id\"\n    }\n]\n", function(key, value) { var v; try { v = eval(value) } catch(e) { v = value } return v;});
return window.JSONImport['example_posts'] = module.exports = item;}, "data/jsons/foundoutabout": function(exports, require, module) {if (!window.JSONImport) window.JSONImport = {};
var item = JSON.parse("[\n    \"Where did you hear from us ?\",\n    \"Friends\",\n    \"Facebook\",\n    \"Search engines\",\n    \"University\",\n    \"ISR members\"\n]\n", function(key, value) { var v; try { v = eval(value) } catch(e) { v = value } return v;});
return window.JSONImport['foundoutabout'] = module.exports = item;}, "data/jsons/routes": function(exports, require, module) {if (!window.JSONImport) window.JSONImport = {};
var item = JSON.parse("{\"Home\":[\"/\",\"/about\",\"/membership\"],\"Posts\":\"/posts\",\"Events\":\"/events\",\"About\":\"/about\",\"Members Benefits\":\"/membership\",\"Student Guide\":\"/student-guide\",\"Partners\":\"/partners\",\"Projects\":\"/projects\",\"Spawn\":\"/spawn\",\"order\":[\"Home\",\"About\",\"Members Benefits\",\"Events\",\"Projects\",\"Spawn\",\"Partners\",\"Posts\"],\"nocontroller\":[false,true,true,false,false,false,false,false],\"isStaticPage\":[false,true,true,false,true,true,true,false],\"implemented\":[true,true,true,true,true,true,true,true]}", function(key, value) { var v; try { v = eval(value) } catch(e) { v = value } return v;});
return window.JSONImport['routes'] = module.exports = item;}, "data/jsons/sg_sections": function(exports, require, module) {if (!window.JSONImport) window.JSONImport = {};
var item = JSON.parse("{\"About Rotterdam\":{\"_ss\":\"Introduction,Demographics,History\",\"Hot Spots\":{\"_ss\":\"Stadhuisplein,Blaak,Beurs,Witte de With,Oude Haven,Oude Binnenweg,Lijnbaan\"},\"Public Transports\":{\"_ss\":\"Ov - Chipkaart,Train,Tram,Bus,Metro,Taxi\"}},\"Administrative & Career\":{\"_ss\":\"Steps to be Taken,Necessary Documents for Registration,Citizen Service Number,Bank Account,Phone Contracts,Health Insurance,Studiefinanciering\",\"Regulations and Careers\":{\"_ss\":\"Laws and Reguations,Working in the Netherlands,Job Hunting Season in Rotterdam,Global Data Collection Company,Professional Career,Internship and Graduate Thesis,Part-Time Job,Job-Seeking Year,Knowledge Migrant,Online Position Information\"},\"Networking\":{\"_ss\":\"Expanding Social Circle,Career Events,Online Presence\"}},\"Housing and Utilities\":{\"_ss\":\"Housing,Gresidence\",\"Other Costs\":{\"_ss\":\"Utilities,Gas and Electricity,Water,Remission,Internet and TV,Taxes\"}},\"Culture and Entertainment\":{\"_ss\":\"Blaak ,Oude Haven ,Witte de With ,Oostplein,Ordering In\",\"Eating Out\":{\"_ss\":\"Amigo,Cafe Plein,Coconuts,Cafe`t Fust Rotterdam,Sorbonne,Divoza,BramLadage,Ezprezzo,Brood Express\"},\"Day Life\":{\"_ss\":\"Outdoor Activities,Pathe,Holland Casino,Lasergame Rotterdam,Exitgame\"},\"Museums\":{\"_ss\":\"Boijmans van Beuiningen Museum,Kunsthal,Wereldmuseum,Maritiem Museum,Others\"},\"Night Life\":{\"_ss\":\"Party Guide,The Partying Need-to-Knows,Night Shops\"},\"Bars and Clubs\":{\"_ss\":\"Locus Publicus,De Witte Aap,Cafe Bed,Toffler,Perron,Bird,Club Cinema\"}},\"Health and Lifestyle\":{\"_ss\":\"Doctors,Dentists,Commodity Market Rotterdam,Bicycles\",\"Useful Information\":{\"_ss\":\"Rotterdampas,Rotterdam Welcome Card,ISR`s Member Card\"},\"Study Spots\":{\"_ss\":\"Central Library,Caffe Belmondo,Coffee Company\"}}}", function(key, value) { var v; try { v = eval(value) } catch(e) { v = value } return v;});
return window.JSONImport['sg_sections'] = module.exports = item;}});
