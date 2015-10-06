'use strict'

EventsResource = (Resty, amMoment) ->
  className = 'Events'
  # coffeelint: disable=max_line_length
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
      menu:
        allowCategoryKeys: ['SmallPlate','Main','Dessert','Drink']

      setting:
        isExclusive: false   # invite Only
        denyGuestShare: false # guests can share event, same as denyForward
        denyRsvpFriends: false # guests can rsvp friends
        rsvpFriendsLimit: 12 # guests rsvp limit for friends
        allowSuggestedFee: false # monentary fee in lieu of donation
        allowPublicAddress: false    # only guests see address
        denyParticipantList: false # guests can see Participants
        denyMaybeNoResponseList: false
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
    3:
      # what
      title: "Tailgate on the Farm"
      description: """
      Join us on the Farm for our season opening tailgate
      as the Cardinal looks to build on their Pac-12 lead.
      Stop by for a beer, some BBQ, hot wings, and more;
      then settle in to watch that McCaffery kid run wild!
      """
      category: "Potluck"     # [Potluck|Popup]
      cusine: "American"      # [American|Japanese|California|Seafood|etc.]
      style: 'Casual'         # [Seated|Casual|Grazing|Picnic]
      attire: 'Casual'        # [Casual|Cocktail|Business|Formal|Fun]
      inspiration: "Go Stanford!"
      aspiration: 2           # 0-3 stars
      price: null             # guest can contribute money?

      heroPic: "http://x.pac-12.com/sites/default/files/styles/event_page_content__hero/public/STAN-FB-SPRING-3__1428795219.jpg"

      # when: 4=Thur
      startTime: moment(new Date('2015-10-03')).hour(17).toJSON() # search/filter
      duration: moment.duration(3, 'hours').asMilliseconds()

      # where:
      neighborhood: "Stanford Stadium, Palo Alto"
      address: 'El Camino Grove'
      location: [37.436191, -122.159668] # search/filter

      seatsTotal: 25
      seatsOpen: null

      # host:
      ownerId: "10" # belongsTo Users
      isPublic: true # searchable

      # guests:  # habtm Users
      # menu:    # menu ideas
      menu:
        allowCategoryKeys: ['Side','Main','Dessert','Drink']

      setting:
        isExclusive: false   # invite Only
        denyGuestShare: false # guests can share event, same as denyForward
        denyRsvpFriends: false # guests can rsvp friends
        rsvpFriendsLimit: 12 # guests rsvp limit for friends
        allowSuggestedFee: false # monentary fee in lieu of donation
        allowPublicAddress: true    # only guests see address
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
    4:
      # what
      title: "Last Days of Summer"
      description: """
      Come on over, we're having a BBQ before it's too late.
      """
      category: "Potluck"     # [Potluck|Popup]
      cusine: "American"      # [American|Japanese|California|Seafood|etc.]
      style: 'Casual'         # [Seated|Casual|Grazing|Picnic]
      attire: 'Casual'        # [Casual|Cocktail|Business|Formal|Fun]
      inspiration: ""
      aspiration: 2           # 0-3 stars
      price: null             # guest can contribute money?

      heroPic: "http://4.bp.blogspot.com/-j8vStXRoslU/UHziypEdbLI/AAAAAAAAJgY/XaKiB0G68_U/s1600/Indian_Summer_99_11.jpg"

      # when: 4=Thur
      startTime: moment(new Date('2015-10-3')).hour(16).startOf('hour').toJSON() # search/filter
      duration: moment.duration(5, 'hours').asMilliseconds()

      # where:
      neighborhood: "Lozenets, Sofia"
      address: 'Ulitsa Bogatitsa'
      location: [42.671027, 23.316299] # search/filter

      seatsTotal: 12
      seatsOpen: null

      # host:
      ownerId: "10" # belongsTo Users
      isPublic: true # searchable

      # guests:  # habtm Users
      # menu:    # menu ideas

      setting:
        isExclusive: false   # invite Only
        denyGuestShare: false # guests can share event, same as denyForward
        denyRsvpFriends: false # guests can rsvp friends
        rsvpFriendsLimit: 12 # guests rsvp limit for friends
        allowSuggestedFee: false # monentary fee in lieu of donation
        allowPublicAddress: false    # only guests see address
        denyParticipantList: false # guests can see Maybe,No responses
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
  

  service = new Resty(data, className)

  service.selectOptions = {
    'category':   ['Potluck', 'Popup']
    'style':      ['Seated','Casual','Grazing','Picnic']
    'attire':     ['Casual','Cocktail','Business','Formal','Fun']
    'cuisine':    ['American','Balkan','California','French','Italian','Japanese','Modern','Thai','Seafood']
  }
  # coffeelint: enable=max_line_length

  # static methods
  service.humanizeSettings = (settings, target='humanize')->
    # humanize setting values by expressing settings in postive form
    humanize = {
      'denyGuestShare'     : 'allowGuestShare' # guests can share event, same as denyForward
      'denyRsvpFriends'    : 'allowRsvpFriends' # guests can rsvp friends
      'denyParticipantList': 'allowParticipantList' # guests can see Participants
      'denyMaybeNoResponseList' : 'allowMaybeNoResponseList' # guests can see Maybe,No responses
      'denyAddMenu'        : 'allowAddMenu'    # only host can update menu Items
      'denyWaitlist'        : 'allowWaitlist'
    }
    dbForm = {
      'allowGuestShare'     : 'denyGuestShare' # guests can share event, same as denyForward
      'allowRsvpFriends'    : 'denyRsvpFriends' # guests can rsvp friends
      'allowParticipantList': 'denyParticipantList' # guests can see Participants
      'allowMaybeNoResponseList':'denyMaybeNoResponseList' # guests can see Maybe,No responses
      'allowAddMenu'        : 'denyAddMenu'     # only host can update menu Items
      'allowWaitlist'       : 'denyWaitlist'
      
    }
    lookup =
      if target=='humanize'
      then humanize
      else dbForm
    copy = {}
    
    if target=='humanize'
      missingKeys = _.difference _.keys( humanize), _.keys(settings)
      _.each missingKeys, (k)->
        # patch missing keys, default=false
        settings[k] = false
        return

    _.each settings, (v, k)->

      if !lookup[k]
        copy[k] = settings[k]
      else
        copy[ lookup[k] ] = !settings[k] #invert value
      return
    return copy


  return service


EventsResource.$inject = ['Resty','amMoment']

angular.module 'starter.core'
  .factory 'EventsResource', EventsResource