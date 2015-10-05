'use strict'

plStarRatings = ($compile) ->
  return {
    restrict: 'AE'
    replace: true
    template: '<div class="text-center"></div>'
    scope: {
      value: '='
      readOnly: '&'
      onClick: '&'
    }
    link: (scope, element, attrs) ->
      scope.minValue = attrs.minValue || 0
      scope.maxValue = attrs.maxValue || 5
      scope.value = scope.minValue if !scope.value
      scope.iconOn = 'ion-ios-star'
      scope.iconOff = 'ion-ios-star-outline'
      scope.starClicked = (val) ->
        console.log "StarRating=" + val
        return if scope.readOnly()
        scope.value = val
        scope.onClick({value:val})
        return
      # markup = """
      # <span class="icon {{ value >= index ? iconOn : iconOff }}" ng-click="starClicked(index)"></span>
      # """
      markup = '<span class="icon" ng-class="{\'' +
        scope.iconOn + '\':value>=index, \'' +
        scope.iconOff + '\':value<index' +
        '}" ng-click="starClicked(index)"></span>'
      scope.$watch 'value', () ->
        scope.value = Math.round(scope.value || 0)
        scope.value = scope.minValue if scope.value < scope.minValue
        scope.value = scope.maxValue if scope.value > scope.maxValue
        element.empty()
        for i in [1..scope.maxValue]
          element.append(markup.replace(/index/g, i))
        return $compile( element.contents())(scope)

      return


  }


plStarRatings.$inject = ['$compile']

angular
  .module 'starter.core'
  .directive 'plStarRatings', plStarRatings