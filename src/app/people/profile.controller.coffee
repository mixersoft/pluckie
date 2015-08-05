'use strict'

ProfileCtrl = ($log) ->
  vm = this
  vm.title = 'Profile'
  $log.info "Creating ProfileCtrl"

ProfileCtrl.$inject = ['$log']

angular.module 'starter.home'
  .controller 'ProfileCtrl', ProfileCtrl
