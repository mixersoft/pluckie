'use strict'

EventsResource = (Resty, amMoment) ->
  data = {
    0:
      # what
      title: "Ramen For That!"
      description: """
        Everything in life should start and end with food. Live by that rule and kickstart your week with an amazing Ramen-fest, Ramen Hello !!
        Blending old world flavors with new world ingredients we bring a unique twist to the traditional delight. Join us as we break the rules , Ichigo-Ichie!
        """
      category: "Potluck"     # [Potluck|Popup]
      cusine: "Japanese"      # [American|Japanese|California|Seafood|etc.]
      style: 'Seated'         # [Seated|Casual|Grazing|Picnic]
      attire: 'Casual'        # [Casual|Cocktail|Business|Formal|Fun]
      inspiration: "Just because I miss my days in Tokyo"
      aspiration: 2           # 0-3 stars

      heroPic: "http://danielfooddiary.com/wp-content/uploads/2013/09/ippudosg3.jpg"

      # when: 4=Thur
      startTime: moment().weekday(7).add(14,'d').hour(20).startOf('hour').toJSON() # search/filter
      duration: moment.duration(3, 'hours').asMilliseconds()

      # where:
      neighborhood: "Dragalevtsi, Sofia"
      address: '23b Dragalevtsi'
      location: [42.629065, 23.316999] # search/filter
      seatsTotal: 12
      seatsOpen: 12

      # host:
      ownerId: "0" # belongsTo Users
      isPublic: true # searchable

      # contributors: {}      # see vm.lookup['Contributions']
      # menu:    # menu ideas
      # menuItems: {}         # see vm.lookup['MenuItems']

      setting:
        # isExclusive: false   # invite Only
        # canForward: true     # guests can forward invites
        # hideAddress: true    # only guests see address
        # hasWaitlist: true    # use waitlist if full
        # feedVisibility: "public"  # [public|guests|none]
        # fixedMenu: false    # only host can update menu Items
        isExclusive: false   # invite Only
        denyForward: false     # guests can forward invites
        denyGuestShare: false # guests can share event, same as denyForward
        denyRsvpFriends: false # guests can rsvp friends
        rsvpFriendsLimit: 12 # guests rsvp limit for friends
        allowSuggestedFee: false # monentary fee in lieu of donation
        allowPublicAddress: false    # only guests see address
        denyParticipantList: false # guests can see Participants
        denyWaitlist: true    # use waitlist if full
        feedVisibility: "public"  # [public|guests|none]
        denyAddMenu: false    # only host can update menu Items

      wrapUp:
        rating: null          # guest ratings

      controlPanel:
        yes: 0
        maybe: 0
        no: 0

    1:
      # what
      title: "Pizza Night"
      description: """
        Enjoy a delightful dinner tasting different pizzas, made with only the best ingredients.
        Bring your favorite Italian wines to share.
        """
      category: "Potluck"     # [Potluck|Popup]
      cusine: "Italian"      # [American|Japanese|California|Seafood|etc.]
      style: 'Seated'         # [Seated|Casual|Grazing|Picnic]
      attire: 'Casual'        # [Casual|Cocktail|Business|Formal|Fun]
      inspiration: "just because"
      aspiration: 1           # 0-3 stars
      price: null             # guest can contribute money?

      heroPic: "http://slice.seriouseats.com/images/20111208-basil-duo.jpg"

      # when: 4=Thur
      startTime: moment().weekday(6).add(14,'d').hour(17).startOf('hour').toJSON() # search/filter
      duration: moment.duration(3, 'hours').asMilliseconds()

      # where:
      neighborhood: "Lozenets, Sofia"
      address: 'ul. "Neofit Rilski" 18'
      location: [42.690626, 23.316678] # search/filter
      seatsTotal: 12
      seatsOpen: 12

      # host:
      ownerId: "1" # belongsTo Users

      # guests:  # habtm Users
      # menu:    # menu ideas

      setting:
        isExclusive: false   # invite Only
        denyForward: false     # guests can forward invites
        denyGuestShare: false # guests can share event, same as denyForward
        denyRsvpFriends: false # guests can rsvp friends
        rsvpFriendsLimit: 12 # guests rsvp limit for friends
        allowSuggestedFee: false # monentary fee in lieu of donation
        allowPublicAddress: false    # only guests see address
        denyParticipantList: false # guests can see Participants
        denyWaitlist: true    # use waitlist if full
        feedVisibility: "public"  # [public|guests|none]
        denyAddMenu: true    # only host can update menu Items

      wrapUp:
        rating: null          # guest ratings

      controlPanel:
        yes: 0
        maybe: 0
        no: 0
    2:
      # what
      title: "American BBQ"
      description: """
      Join us for a quick a cultural tour of American-a - with a sampling of my favorite regional BBQs
      """
      category: "Potluck"     # [Potluck|Popup]
      cusine: "American"      # [American|Japanese|California|Seafood|etc.]
      style: 'Casual'         # [Seated|Casual|Grazing|Picnic]
      attire: 'Casual'        # [Casual|Cocktail|Business|Formal|Fun]
      inspiration: "здравей софия"
      aspiration: 3           # 0-3 stars
      price: null             # guest can contribute money?

      heroPic: "http://whatscookingamerica.net/Beef/Beef-Brisket/Brisket-final2.jpg"

      # when: 4=Thur
      startTime: moment(new Date('2015-09-12')).hour(16).startOf('hour').toJSON() # search/filter
      duration: moment.duration(5, 'hours').asMilliseconds()

      # where:
      neighborhood: "Lozenets, Sofia"
      address: 'Ulitsa Bogatitsa'
      location: [42.671027, 23.316299] # search/filter

      seatsTotal: 20
      seatsOpen: null

      # host:
      ownerId: "10" # belongsTo Users
      isPublic: true # searchable

      # guests:  # habtm Users
      # menu:    # menu ideas

      setting:
        isExclusive: false   # invite Only
        denyForward: false     # guests can forward invites
        denyGuestShare: false # guests can share event, same as denyForward
        denyRsvpFriends: false # guests can rsvp friends
        rsvpFriendsLimit: 12 # guests rsvp limit for friends
        allowSuggestedFee: false # monentary fee in lieu of donation
        allowPublicAddress: false    # only guests see address
        denyParticipantList: false # guests can see Participants
        denyWaitlist: true    # use waitlist if full
        feedVisibility: "public"  # [public|guests|none]
        denyAddMenu: false    # only host can update menu Items

      wrapUp:
        rating: null          # guest ratings

      controlPanel:
        yes: 0
        maybe: 0
        no: 0

  }
  return service = new Resty(data)


EventsResource.$inject = ['Resty','amMoment']

angular.module 'starter.core'
  .factory 'EventsResource', EventsResource