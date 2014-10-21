class Application extends IS.Object
    (@getStylesFunc) ~>
        document.title = AppInfo.displayname
        @LifeCycle = new IS.Promise!
        @LifeCycle.then @fixMobile .then @loadDepMan .then @getStyles .then @loadPayload .then @loadLibs .then @loadEssentials .then @bootStrapAngular .then @renderPage .then @checkDevMode .then @completeLoad
        window.Tester = new (require "classes/helpers/Tester")(~> @LifeCycle.resolve!)

    checkDevMode: ~>
        if window.isDev?
            document.title = "Testing #{window.AppInfo.displayname}!"
            Debug.enable \app:*
        @LifeCycle.resolve!
    loadDepMan: ~> window.DepMan = new (require "classes/helpers/DepMan"); @LifeCycle.resolve!
    fixMobile: ~>
        meta = document.createElement "meta"
        meta.setAttribute "name", "viewport"
        meta.setAttribute "content", "height=device-height, width=device-width, user-scalable=no, initial-scale=1, maximum-scale=1, minimum-scale=1"
        document.head.appendChild meta
        meta = document.createElement "link"
        meta.setAttribute "rel", "apple-touch-icon"
        meta.setAttribute "href", "icon.ico"
        document.head.appendChild meta
        meta = document.createElement "meta"
        meta.setAttribute "name", "apple-mobile-web-app-capable"
        meta.setAttribute "content", "yes"
        document.head.appendChild meta
        meta = document.createElement \link
        meta.set-attribute \rel, \icon
        meta.set-attribute \href, \icon.ico
        document.head.appendChild meta
        @LifeCycle.resolve!
    loadEssentials: ~>
        base = document.createElement "base"
        base.setAttribute "href", "/"
        document.head.appendChild base
        window.DBStorage = new (DepMan.helper "Storage")(~> @LifeCycle.resolve!)
    getStyles: ~> 
        styles = @getStylesFunc!
        styles.addEventListener "load", ~> 
            DepMan.stylesheet \fullcalendar
            DepMan.stylesheet \angular-material
            DepMan.stylesheet \focuspoint
            @LifeCycle.resolve!
        document.head.append-child styles
    loadPayload: ~> 
        DepMan.ext-script "/js/#{AppInfo.name}.payload.js", ~> @LifeCycle.resolve!

    loadLibs: ~>
        window.jQuery = window.$ = DepMan.lib \jquery
        window <<< DepMan.lib \fb
        window <<< DepMan.lib \angular
        # window <<< DepMan.lib \angular.animate.stylers
        window <<< DepMan.lib \angular.route
        window <<< DepMan.lib \angular.animate
        window <<< DepMan.lib \angular.material
        window <<< DepMan.lib \markdown
        window <<< DepMan.lib \epiceditor
        window <<< DepMan.lib \stackBlur
        window <<< DepMan.lib \focuspoint
        window <<< DepMan.lib \jquery-ui
        window <<< DepMan.lib \jquery-scrollto
        window <<< async: DepMan.lib \async
        window <<< moment: DepMan.lib \moment
        window <<< prelude: (DepMan.lib \prelude-browser) "prelude-ls"
        window <<< DepMan.lib \ui-bootstrap
        window <<< DepMan.lib \fullcalendar
        window <<< DepMan.lib \gcal
        window <<< DepMan.lib \calendar

        window.Hammer = DepMan.lib "hammer"
        window.Debug = DepMan.lib \debug

        window.Debug.disable \*

        DepMan.extLink "//maxcdn.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css"
        @LifeCycle.resolve!

    renderPage: ~>
        wrapper = document.createElement "div"
        wrapper.setAttribute "id", "wrapper"
        wrapper.innerHTML = DepMan.render "index"
        $ document.body .append wrapper 
        @LifeCycle.resolve!

    bootStrapAngular: ~>
        app = angular.module AppInfo.displayname, ["ngRoute", "ngAnimate", "ngMaterial", "ui.calendar"] .config ["$locationProvider", (location) ->
            location.html5Mode true
        ]
        app.run ["$templateCache", (templates) !->
            for i in [0 til SrcInfo.data.views.partials.length] then templates.put SrcInfo.data.views.partials[i], DepMan.render "partials/#{SrcInfo.data.views.partials[i]}"
        ]
        for i in [0 til SrcInfo.classes.directives.length] then DepMan.directive SrcInfo.classes.directives[i]
        for i in [0 til SrcInfo.classes.controllers.length] then DepMan.controller SrcInfo.classes.controllers[i]
        @LifeCycle.resolve!

    completeLoad: ~>
        window.FB.init appId: '353273218168906', xfbml: false, version: 'v2.1', status: true
        angular.bootstrap ($ '#wrapper' .0) , [AppInfo.displayname]

module.exports = Application
