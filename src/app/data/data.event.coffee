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
      inspiration: "Just because I miss my days in Tokyo"
      aspiration: 2           # 0-3 stars

      heroPic: "https://noisynoodler.files.wordpress.com/2013/06/tonkotsu-ramen.jpg"

      # when: 4=Thur
      startTime: moment().day(4).hour(20).startOf('hour').toJSON() # search/filter
      duration: moment.duration(3, 'hours').asMilliseconds()

      # where:
      neighborhood: "Lozenets, Sofia"
      address: 'Blvd "James Bourchier" 83'
      location: [42.671027, 23.316299] # search/filter
      seats: 12

      # host:
      ownerId: "0" # belongsTo Users
      isPublic: true # searchable

      participants: {  # indexBy userId
        # add host participation record
        '1':
          userId: '1'
          seats: 1
          comment: 't-shirt ramen!'
        '2':
          userId: '2'
          seats: 3
          comment: 'the whole family is excited!!!'
      }        # habtm Users
      contributors: {}        # set by getContributions()
      # menu:    # menu ideas
      menuItemIds: [10..14]   # TODO: use habtm Contribution
      menuItems: {}           # set by getMenuItems()

      setting:
        isExclusive: false   # invite Only
        canForward: true     # guests can forward invites
        hideAddress: true    # only guests see address
        hasWaitlist: true    # use waitlist if full
        feedVisibility: "public"  # [public|guests|none]
        fixedMenu: false    # only host can update menu Items

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
      inspiration: "just because"
      aspiration: 1           # 0-3 stars
      price: null             # guest can contribute money?

      heroPic: "http://slice.seriouseats.com/images/20111208-basil-duo.jpg"

      # when: 4=Thur
      startTime: moment().day(6).hour(17).startOf('hour').toJSON() # search/filter
      duration: moment.duration(3, 'hours').asMilliseconds()

      # where:
      neighborhood: "Lozenets, Sofia"
      address: 'ul. "Neofit Rilski" 18'
      location: [42.690626, 23.316678] # search/filter
      seats: 8

      # host:
      ownerId: "1" # belongsTo Users

      # guests:  # habtm Users
      # menu:    # menu ideas
      menuItemIds: [0..3]    # TODO: use habtm Contribution

      setting:
        isExclusive: false   # invite Only
        canForward: true     # guests can forward invites
        hideAddress: true    # only guests see address
        hasWaitlist: true    # use waitlist if full
        feedVisibility: "public"  # [public|participants|host]
        fixedMenu: false    # only host can update menu Items

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
        We've got the BBQ and smoker fired up for some amazing pork cooked low 'n slow!'
        """
      category: "Potluck"     # [Potluck|Popup]
      cusine: "American"      # [American|Japanese|California|Seafood|etc.]
      inspiration: "Everything Pork"
      aspiration: 1           # 0-3 stars
      price: null             # guest can contribute money?

      heroPic: "http://www.foodpeoplewant.com/wp-content/uploads/2010/06/Peach-BBQ-Spare-Ribs.jpg"

      # when: 4=Thur
      startTime: moment().day(7).hour(13).startOf('hour').toJSON() # search/filter
      duration: moment.duration(3, 'hours').asMilliseconds()

      # where:
      neighborhood: "Dragalevtsi, Sofia"
      address: '23b Dragalevtsi'
      location: [42.629065, 23.316999] # search/filter
      seats: 16

      # host:
      ownerId: "2" # belongsTo Users
      isPublic: true # searchable

      # guests:  # habtm Users
      # menu:    # menu ideas
      menuItemIds: [4..9]    # TODO: use habtm Contribution
      contributionIds: {} # join table: event | menuItem | user

      setting:
        isExclusive: false   # invite Only
        canForward: true     # guests can forward invites
        hideAddress: true    # only guests see address
        hasWaitlist: true    # use waitlist if full
        feedVisibility: "public"  # [public|guests|none]
        fixedMenu: false    # only host can update menu Items

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