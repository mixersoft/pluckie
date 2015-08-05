'use strict'

HomeCtrl = ($log, toastr) ->
  vm = this
  vm.title = "Home"
  $log.info "Creating HomeCtrl"
  toastr.info "Creating HomeCtrl"


HomeCtrl.$inject = ['$log', 'toastr']

angular.module 'starter.home'
  .controller 'HomeCtrl', HomeCtrl
