'use strict'

# helper functions for managing user actions on events
EventActionHelpers = ($rootScope, $q, $timeout
  $location, $state, $stateParams, $ionicPopup
  TokensResource, ParticipationsResource
  appModalSvc
  $log, toastr)->

  passcodePopup = {
    template: '<input type="password" ng-model="passcode">',
    title: "Update Response"
    subTitle: 'Enter your passcode to update this response',
    cssClass: 'passcode-popup'
    scope: null
    buttons: [
      { text: 'Cancel' }
      {
        text: 'OK'
        type: 'button-positive'
        onTap: (e)->
          passcode = angular.element(e.currentTarget).scope().passcode
          e.preventDefault() if !passcode
            # //don't allow the user to close unless he enters passcode password
          return passcode if passcode
      }
    ]
  }



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
              return false

              if type.currentTarget # event
                return false # let a.href handle it naturally

              if ionic.Platform.isWebView()
                return false
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
    #     also use repsonse modal to update participation
    ###
    beginResponse: (person, event)->
      vm = this
      return $q.when()
      .then ()->
        if person && person == vm.lookup['Participations'][person.id]
          participation = person
          # recover anonymous response with passcode
          return $ionicPopup.show(passcodePopup)
          .then (response)->
            key = ParticipationsResource.setResponseId(person, response, 'peek')
            return participation if key == participation.responseId
            toastr.warning "The passcode did not match"
            return $q.reject('WARNING: The passcode did not match or records')
      .then (participation)->
        options = {}
        participation = vm.getParticipationByUser(person) if !participation
        if $state.is('app.event-detail.invitation')
          # assume invitation is valid if we got this far
          return $q.reject('INVALID') if !$state.params.invitation
        if $state.is('app.event-detail')
          # return OK if there is a No/Maybe response
          return $q.reject('INVALID') if !participation

        if participation
          options['displayName'] = participation.responseName
          options['active'] = participation.response
          options['seats'] = participation.seats
          options['comment'] = participation.comment
          # TODO: shouldn't extract passcode here, 
          # just offer user a chance to change passcode, and save to server
          options['passcode'] = participation.responseId?.split('~').shift()
        if person?.displayName # override
          options['displayName'] = person.displayName
        return options

      .then (options={})->
        $log.info options
        return appModalSvc.show('events/respond.modal.html', vm, {
          mm:   # mm == "modal model" instead of view model
            active: options['active'] || null
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
              if vm.me && myResponse.person?.id != vm.me.id
                toastr.warning("You are booking for a different person. name=" +
                  myResponse.person.displayName)
              if myResponse.person?.id
                toastr.info("You are updating your response")
              if myResponse.response.seats < 1
                toastr.warning("You must respond for at least 1 person")

              myResponse.response['value'] = this.active
              return promise = self.saveResponse.call(vm, myResponse)
              .then (result)->
                onSuccess?(result)
                return result


          myResponse :
            person: person
            event: event
            response:
              value: options['active']  # set in submitResponse(), [No|Maybe|Yes]
              displayName: options['displayName'] || person?.displayName
              passcode: options['passcode']
              seats: options['seats'] || 1
              comment: options['comment']
        })
      .then (result)->
        $log.info "Contribute Modal resolved, result=" + JSON.stringify result
      .catch (err)->
        toastr.warning "Expecting an invitation" if err == "INVALID"


    ###
    @description create/update an invitation response
    applies to Yes|Maybe|No, save to ParticipationResource
    ###
    saveResponse: (myResponse)->
      vm = this
      response = myResponse.response
      participation = vm.getParticipationByUser(myResponse.person)
      return $q.when()
      .then ()->
        data = {
          eventId: myResponse.event.id
          participantId: myResponse.person?.id || null
          response: response.value
          seats: response.seats
          comment: response.comment
          responseId: null  # set by ParticipationsResource.setResponseId()
          responseName: response.displayName
        }
        switch response.value
          when 'Yes'
            # require valid user, anonymous response not allowed
            toastr.warning "Expecting Yes response with valid user" if data.participantId==null
          when 'Maybe','No'
            ParticipationsResource.setResponseId( data, response.passcode) if !data.participantId
        if data['participantId'] # final cleanup
          data['responseName'] = data['responseId'] = null
        if participation
          return ParticipationsResource['put'](participation.id, data)
        return ParticipationsResource['post'](data)
      .then (result)->
        # for anonymous responses, look for response in vm.me.participation, delete on sign-in
        _.extend vm.me.participation, result if vm.me.participation?
        vm.me['participation'] = result if _.isEmpty vm.me

        if result.responseId
          toastr.info "Please use passcode='" + response.passcode + "' to update your response."

        $rootScope.$broadcast 'event:participant-changed', result
        return $log.info result





  }
  
  return self # EventActionHelpers


EventActionHelpers.$inject = ['$rootScope', '$q', '$timeout'
'$location', '$state', '$stateParams', '$ionicPopup'
'TokensResource', 'ParticipationsResource'
'appModalSvc'
'$log', 'toastr']


angular.module 'starter.events'
  .factory 'EventActionHelpers', EventActionHelpers
