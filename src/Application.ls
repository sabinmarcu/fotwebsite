class Application extends IS.Object
    (@getStylesFunc) ~>
        document.title = AppInfo.displayname
        @LifeCycle = new IS.Promise!
        @LifeCycle.then @fixMobile, (->), @progress .then @loadDepMan, (->), @progress .then @getStyles, (->), @progress .then @loadPayload .then @loadLibs, (->), @progress .then @loadEssentials, (->), @progress .then @bootStrapAngular, (->), @progress .then @renderPage, (->), @progress .then @checkDevMode, (->), @progress .then @completeLoad, (->), @progress
        window.Tester = new (require "classes/helpers/Tester")(~> @LifeCycle.resolve!)

    progress: ~>
        p = document.querySelector ".seoflier .percent"
        if p? then p.innerHTML = it
    checkDevMode: ~>
        @LifeCycle.progress 90
        if window.isDev?
            document.title = "Testing #{window.AppInfo.displayname}!"
            scr = document.createElement "script"
            scr.src = "http://#{(location.host or 'localhost').split ':' .0}:35729/livereload.js?snipver=1"
            document.head.appendChild scr
            Debug.enable \app:*
        @LifeCycle.resolve!
    loadDepMan: ~> 
        window.DepMan = new (require "classes/helpers/DepMan"); 
        @LifeCycle.progress 20
        @LifeCycle.resolve!
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
        @LifeCycle.progress 10
        @LifeCycle.resolve!
    loadEssentials: ~>
        @LifeCycle.progress 60
        base = document.createElement "base"
        base.setAttribute "href", "/"
        document.head.appendChild base
        window.DBStorage = new (DepMan.helper "Storage")(~> @LifeCycle.resolve!)
    getStyles: ~> 
        styles = @getStylesFunc!
        @LifeCycle.progress 30
        styles.addEventListener "load", ~> 
            DepMan.stylesheet \fullcalendar
            DepMan.stylesheet \angular-material
            DepMan.stylesheet \focuspoint
            DepMan.google-font "Open Sans", [100, 300], ["latin"]
            DepMan.google-font "Open Sans Condensed", [100, 300], ["latin"]
            @LifeCycle.resolve!
        document.head.append-child styles
    loadPayload: ~> 
        @LifeCycle.progress 40
        DepMan.ext-script "/js/#{AppInfo.name}.payload.js", 
            DepMan.ext-script "/js/#{AppInfo.name}.config.js", ~> @LifeCycle.resolve!

    loadLibs: ~>
        @LifeCycle.progress 50
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
        window <<< DepMan.lib \randColor

        window.Hammer = DepMan.lib "hammer"
        window.Debug = DepMan.lib \debug

        window.Debug.disable \*

        window <<< DepMan.lib "angular.hammer"

        DepMan.extLink "//maxcdn.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css"
        @LifeCycle.resolve!

    renderPage: ~>
        @LifeCycle.progress 80
        wrapper = document.createElement "div"
        wrapper.setAttribute "id", "wrapper"
        wrapper.innerHTML = DepMan.render "index"
        $ document.body .append wrapper 
        @LifeCycle.resolve!

    bootStrapAngular: ~>
        @LifeCycle.progress 70
        app = angular.module AppInfo.displayname, ["ngRoute", "ngAnimate", "ngMaterial", "ui.calendar", "hmTouchEvents"] .config ["$locationProvider", (location) ->
            location.html5Mode true
        ]
        app.run ["$templateCache", (templates) !->
            for i in [0 til SrcInfo.data.views.partials.length] then templates.put SrcInfo.data.views.partials[i], DepMan.render "partials/#{SrcInfo.data.views.partials[i]}"
        ]
        for i in [0 til SrcInfo.classes.directives.length] then DepMan.directive SrcInfo.classes.directives[i]
        for i in [0 til SrcInfo.classes.controllers.length] then DepMan.controller SrcInfo.classes.controllers[i]
        @LifeCycle.resolve!

    completeLoad: ~>
        @LifeCycle.progress 100
        window.FB.init appId: '353273218168906', xfbml: false, version: 'v2.1', status: true
        angular.bootstrap ($ '#wrapper' .0) , [AppInfo.displayname]

module.exports = Application
