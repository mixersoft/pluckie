'use strict'

# from http://codepen.io/jdnichollsc/pen/qOrqqK
plMultipleSelect = ($q, $ionicModal, $ionicGesture) ->
  return {
    restrict: 'E'
    scope: {
      options: '='
      onClose: '&'
    }
    link: (scope, element, attrs)->
      scope.multipleSelect = {
        title:            attrs.title || "Select Options",
        tempOptions:      [],
        keyProperty:      attrs.keyProperty || "id",
        valueProperty:    attrs.valueProperty || "value",
        selectedProperty: attrs.selectedProperty || "selected",
        templateUrl:      attrs.templateUrl || 'core/partial.multipleSelect.html',
        renderCheckbox:   if attrs.renderCheckbox then attrs.renderCheckbox == "true" else true
        animation:        attrs.animation || 'slide-in-up'
      }
      scope.OpenModalFromTemplate = (templateUrl)->
        return $ionicModal.fromTemplateUrl(templateUrl, {
          scope: scope,
          animation: scope.multipleSelect.animation
        })
        .then (modal)->
          scope.modal = modal
          scope.modal.show()

      $ionicGesture.on 'tap', (e)->
        multiSelect = scope.multipleSelect
        multiSelect.tempOptions = _.map scope.options, (option)->
          tempOption = {}
          tempOption[multiSelect.keyProperty] = option[multiSelect.keyProperty]
          tempOption[multiSelect.valueProperty] = option[multiSelect.valueProperty]
          tempOption[multiSelect.selectedProperty] = option[multiSelect.selectedProperty]
          return tempOption
        scope.OpenModalFromTemplate(multiSelect.templateUrl)
        return
      , element

      scope.saveOptions = ()->
        multiSelect = scope.multipleSelect
        _.each multiSelect.tempOptions, (tempOption)->
          _.each scope.options, (option)->
            if(tempOption[multiSelect.keyProperty] == option[multiSelect.keyProperty])
              option[multiSelect.selectedProperty] = tempOption[multiSelect.selectedProperty]
              return false
        scope.onClose({options:scope.options})
        scope.closeModal()

      scope.closeModal = ()->
        scope.modal.remove()

      scope.$on '$destroy', ()->
        scope.closeModal() if scope.modal
  }


plMultipleSelect.$inject = ['$q', '$ionicModal', '$ionicGesture']

angular
  .module 'starter.core'
  .directive 'plMultipleSelect', plMultipleSelect