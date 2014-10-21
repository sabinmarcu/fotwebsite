class StaticPageController extends DepMan.controller "Base"
    (@scope, @root, @location) ~>
    @hook ["$rootScope", "$location"]
