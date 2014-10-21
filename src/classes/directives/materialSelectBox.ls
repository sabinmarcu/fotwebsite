class materialSelectBox extends DepMan.controller "Base"
    @hook = ~> 
        restrict: "E"
        transclude: true
        scope: 
            "model": "="
            "elements": "="
            "id": "@"
            "prop": "="
        template: DepMan.render "materialSelectBoxList"
        controller: ["$scope", "$element" ~> new materialSelectBox ...]

    (@scope, @element) ~> 

        @scope.model = "Pick an element from the list"
        @scope.scroll = 0

        if @scope.prop? then @scope.search = {}
        else @scope.search = ""

        @scope.state = false

        window.addEventListener "click", ~> if $ it.target .parents "material-select-box" .length is 0 then @toggle false
        @element.find "material-radio-group" .scroll ~> 
            @scope.scroll = it.target.scrollTop

            it.preventDefault!
            it.stopPropagation!

            @scope.safeApply!

        super ...

    toggle: (value = null) ~>
        if value? then @scope.state = value
        else @scope.state = not @scope.state

    getHeight: ~>
        items = @element.find "material-item"
        height: items.length * items.height!


angular.module AppInfo.displayname .directive "materialSelectBox", materialSelectBox.hook
module.exports = materialSelectBox