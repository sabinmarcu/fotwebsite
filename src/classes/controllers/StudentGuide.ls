class StudentGuideController extends DepMan.controller "Base"
    (@scope, @root, @location) ~>
        @sections = DepMan.json "sg_sections"
        @selected = []; @active = false
        @root.$on "$locationChangeSuccess", ~>
            @active = false
            if @location.path().match "^/student-guide.*"
                @emptySelection!

                m = @location.path!.match /\/student-guide\/([a-zA-Z\-\s]+)\/?/
                if m? then @select decodeURI m.1

                @active = true
                @safeApply!
        window.addEventListener "resize", ~> @safeApply!
        window.addEventListener "orientationchange", ~> @safeApply!
        window.addEventListener "click", (e) ~>
            if @active
                if not (e.target.tagName.toLowerCase! in <[article nav ul li]>) and $ e.target .parents ".sgarticle" .length is 0
                    @emptySelection!
                    @safeApply!
        super ...
        @safeApply!
    getSgFontAndWidths: (title) ~>
        i = 0; size = $ 'nav#sg' .width!
        for k, v of @sections then i += 1
        return {width: size/i - 2, font-size: ((size / i - 2) / ((title.length + 10) * 1.5)) * 3}
    renderArticle: (title) ~>
        name = @getName title
        DepMan.data "views/sg/#name"
    hasArticle: (title) ~>
        name = @getName title
        try
            DepMan.data "views/sg/#name"
            return true
        catch e
            return false
    findTitle: (title, tree = @sections) ~>
        for k, v of tree
            if title is @getName k then return k
            else if v isnt null and not v.substr? 
                res = @findTitle title, v
                if res? then return res
        return null
    findTree: (title, tree = @sections) ~>
        for k, v of tree
            if title is @getName k then return v
            else if v isnt null and not v.substr? 
                res = @findTree title, v
                if res? then return res
        return null
    getSgFont: (title) ~>
        size = (300 / ((title.length + 10) * 1.5)) * 2
        if size > 15 then size = 15
        return {font-size: size}
    select: (title, next = (@findTree title)) !~>
        if next is null
            @emptySelection!
            @selected.push @findTitle title
        else
            if @selected.length > 0 then @emptySelection!
            @selected.push @findTitle title
            @selectTree next
        @location.path "/student-guide/#{@getName title}"
        @safeApply!
        $ "section\#sg" .scrollTo 0
    isInactive: (title) ~>
        if @selected.length is 0 then false
        else if title in @selected then false
        else true
    emptySelection: ~> while @selected.length > 0 then @selected.pop!
    selectTree: (tree) ~>
        for k, v of tree
            if k is "_ss" then v.split "," .map (~> @selected.push it)
            else
                if v is null then @selected.push k
                else @selectTree v
    getName: (title) ~> 
        newtit = title.replace /\ /g, "" .replace /[&'`]/g, "" .replace /\(.*\)/g, ""
        if title[title.length - 1] is ' ' then newtit += " "
        newtit
    getWidth: ~> 
        if window.innerWidth <= 700 then width: window.innerWidth
        else if window.innerWidth <= 1000 then width: window.innerWidth - (250 / 3 * 2) - 75
        else width: window.innerWidth - 325
    @hook ["$rootScope", "$location"]
