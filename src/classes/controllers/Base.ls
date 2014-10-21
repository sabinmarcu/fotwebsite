class BaseController extends require "classes/BaseAngularHook"

    ~> super ... ; @log "Initialized", @; @config-scope!

    activateMenu: ~>
        @scope.$emit "globalmenu:activated"
    config-scope: ~>
        @safeApply = (fn) ~>
            phase = @scope.$parent.$$phase
            if phase is "$apply" or phase is "$digest"
                if fn and (typeof(fn) is 'function')
                    do fn
            else @scope.$apply(fn)
            @
        @scope <<< @

module.exports = BaseController
