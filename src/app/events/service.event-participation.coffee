'use strict'

# helper functions for managing user actions on events
EventActionHelpers = ($rootScope, $q, $timeout
  $location, $state, $stateParams
  TokensResource
  appModalSvc
  $log, toastr)->
  self = {
    getShareLinks: (event)->
      vm = this
      target = null
      return $q.when()
      .then ()->
        return TokensResource.get([$stateParams.invitation]) if $stateParams.invitation
        target = ['Event', event.id].join(':')
        return TokensResource.query({target: target})
      .then (results)->
        # return token if TokensResource.isTokenValid(token)
        tokens = _.filter results, (token)->
          return TokensResource.isTokenValid(token)
        return $q.reject('NONE') if _.isEmpty tokens
        return tokens
      .catch (err)->
        return $q.reject(err) if /EXPIRED|INVALID|NONE/.test(err) == false
        # TODO: check permission to create new Token
        token = {
          ownerId: vm.me.id
          target: target
          views: 0
          expireCount: 100
          expireDate: event.startTime
          accessors:[]
        }
        return TokensResource.post(token).then (token)->
          return [tokens]
      .then (tokens)->
        if ionic.Platform.isWebView()
          origin = "http://app.snaphappi.com/pluckie.App/#"
        else
          path = $location.path()
          origin = $location.absUrl().slice(0, $location.absUrl().indexOf(path))

        eventLink = origin + '/app/event-detail/' + event.id
        shareLinks = {
          'event': if event.setting.isExclusive then false else eventLink
        }
        if event.setting.denyForward && vm.me.id != vm.event.ownerId
          shareLinks['invitations'] = false
        else
          shareLinks['invitations'] = _.map tokens, (token)->
            return {
              link: origin + '/app/invitation/' + token.id
              id: token.id
              views: token.views
              remaining: token.expireCount - token.views
              expires: moment(token.expireDate).fromNow()
            }
        return shareLinks

    showShareLink: (event)->
      vm = this
      return $q.when()
      .then ()->
        return self.getShareLinks.call(vm, event)
      .then (shareLinks)->
        return appModalSvc.show('events/sharing.modal.html', vm, {
          mm:
            item: event
            links: shareLinks
            goto: (type, id)->
              if type == 'invitation' # goto Invite
                state = 'app.event-detail.invitation'
                params = {invitation: id}
              if type == 'event' # goto Event
                state = 'app.event-detail'
                params = {id: id}
              $log.info "TESTING: manually transition to state=" + JSON.stringify [state,id]
              $state.transitionTo(state, params)

        })
      .then (result)-> # closeModal(result)
        return $q.reject('CANCELED') if `result==null` || result == 'CANCELED'
        return $q.reject(result) if result?['isError']
        return result

    ###
    # @description show invitation response modal and handle response
    ###
    beginResponse: (person, event)->
      vm = this
      invitation = $state.params.invitation
      return $q.reject('INVALID') if $state.is('app.event-detail.invitation') == false
      # assume invitation is valid if we got this far
      return $q.when()
      .then ()->
        return appModalSvc.show('events/respond.modal.html', vm, {
          mm:   # mm == "modal model" instead of view model
            active: null
            placeholder: ''
            isActive: (value)->
              return value == this.active if value
              return this.active
            setActive: (value)->
              this.active = value
              this.commentPlaceholder(value)
              return value
            isValidated: (response)->
              return false if this.active == null
              switch this.active
                when 'Yes'
                  return true if vm.acl.isAnonymous() == false
                  return false
                when 'No', 'Maybe'
                  if vm.acl.isAnonymous()
                    return true if response.displayName && response.passcode
                    return false
                  return true
                else
                  return false

            commentPlaceholder: (action)->
              switch action
                when 'No'
                  msg = "Add a message to show you'll be there in spirit."
                when 'Maybe'
                  msg = "Add a message to show your support."
                else
                  msg = "Add a message to announce your participation!"
              # $log.info "placeholder=" + msg
              return this.placeholder = msg

            signInRegister: (action, person)->
              # update booking user after sign in/register
              return vm.on.showSignIn(action)
              .then (result)->
                _.extend person, result
                return

            submitResponse: (ev, myResponse, onSuccess)->
              return if this.isValidated(myResponse['response']) == false
              # some sanity checks
              if vm.event.id != myResponse.event.id
                toastr.warning("You are booking for a different event. title=" +
                  myResponse.event.title)
              if myResponse.person.id && myResponse.person.id != vm.me.id
                toastr.warning("You are booking for a different person. name=" +
                  myResponse.person.displayName)
              if vm.event.participantIds[myResponse.person.id]
                toastr.warning("You are replacing an existing booking for this userId")
              if myResponse.response.seats < 1
                toastr.warning("You must respond for at least 1 person")

              myResponse.response['value']  = this.active  # [No|Maybe|Yes]
              switch myResponse.response['value']
                when 'Yes'
                  myResponse['booking'] = myResponse.response
                  return self.createBooking.call(vm, myResponse).then (result)->
                    onSuccess?(result)
                    return result
                when 'Maybe', 'No'
                  return self.createResponse.call(vm, myResponse.response)
              return

          myResponse :
            person: person
            event: event
            response:
              value: null  # set in submitResponse(), [No|Maybe|Yes]
              displayName: person.displayName || null
              passcode: null
              seats: 1
              comment: null
        })
      .then (result)->
        $log.info "Contribute Modal resolved, result=" + JSON.stringify result
      .catch (err)->
        toastr.warning "Expecting an invitation" if err == "INVALID"


    createResponse: (response)->
      vm = this
      # alias, execute in Controller scope
      return $log.info response

    createBooking: (booking)->
      vm = this
      # alias, execute in Controller scope
      return vm.createBooking(booking)




  }
  
  return self # EventActionHelpers


EventActionHelpers.$inject = ['$rootScope', '$q', '$timeout'
'$location', '$state', '$stateParams'
'TokensResource'
'appModalSvc'
'$log', 'toastr']


angular.module 'starter.events'
  .factory 'EventActionHelpers', EventActionHelpers
