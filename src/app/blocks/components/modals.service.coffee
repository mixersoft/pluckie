'use strict'

###
# @description: reusable $ionicModal service
# see: http://forum.ionicframework.com/t/ionic-modal-service-with-extras/15357
# usage: appModalSvc.show( <templateUrl>, "controller as vm", params )
###
ReusableModal = ($ionicModal, $rootScope, $q, $injector, $controller) ->

  show = (templateUrl, controller, parameters, options)->
    # Grab the injector and create a new scope
    dfd = $q.defer()
    modalScope = $rootScope.$new()
    thisScopeId = modalScope.$id
    ctrlInstance = null
    defaultOptions = {
      animation: 'slide-in-up'
      focusFirstInput: false
      backdropClickToClose: true
      hardwareBackButtonClose: true
      modalCallback: null
    }
    options = angular.extend(defaultOptions, options, {scope : modalScope})

    $ionicModal.fromTemplateUrl( templateUrl, options)
    .then (modal)->
      modalScope.modal = modal

      modalScope.openModal = ()->
        modalScope.modal.show()
      modalScope.closeModal = (result)->
        dfd.resolve(result)
        modalScope.modal.hide()

      modalScope.$on('modal.hidden', (thisModal)->
        if thisModal.currentScope
          modalScopeId = thisModal.currentScope.$id
          if thisScopeId == thisModal.currentScope.$id
            dfd.resolve(null)
            _cleanup(thisModal.currentScope)
      )

      
      if angular.isObject(controller)
        # assume this is the ControllerAs
        modalScope.vm = ctrlInstance = controller
        same = modalScope.vm == modalScope.modal.scope.vm
        ctrlInstance['openModal'] = modalScope.openModal
        ctrlInstance['closeModal'] = modalScope.closeModal
      else
        # invoke the controller
        locals = {
          '$scope': modalScope
          'parameters': parameters
        }
        ctrlEval = _evalController(controller)
        if ctrlEval.controllerName
          ctrlInstance = $controller(controller, locals)

        if ctrlEval.isControllerAs && ctrlInstance
          # adds these methods to ControllerAs
          ctrlInstance['openModal'] = modalScope.openModal
          ctrlInstance['closeModal'] = modalScope.closeModal

      angular.extend(modalScope, parameters) if parameters?    

      return modalScope.modal.show().then ()->
        modalScope.$broadcast 'modal.afterShow', modalScope.modal
        options.modalCallback?(modal)

    , (err)->
      dfd.reject(err)

    return dfd.promise

  _cleanup = (scope)->
    scope.$destroy()
    scope.modal.remove() if scope.modal
    return

  # parse controllerAs fragment, e.g. controllerAs = "MyCtrl as vm"
  _evalController = (ctrlName = '')->
    result = {
      isControllerAs: false
      controllerName: ''
      propName: ''
    }
    fragments = ctrlName.trim().split(/\s+/)
    result.isControllerAs = fragments.length == 3 && (fragments[1] || '').toLowerCase() == 'as'
    if result.isControllerAs
      result.controllerName = fragments[0]
      result.propName = ctrlName
    else
      result.controllerName = ctrlName
    return result


  return {
    show: show
  }




ReusableModal.$inject = ['$ionicModal', '$rootScope', '$q', '$injector', '$controller']

angular.module 'blocks.components'
  .factory 'appModalSvc', ReusableModal


