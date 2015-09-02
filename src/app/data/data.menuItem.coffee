'use strict'

MenuItemsResource = (Resty, amMoment) ->
  # Event hasMany MenuItems
  # coffeelint: disable=max_line_length
  data = {
    0:
      title   : "Tomatoes and Foccacia with Tomatoes"
      detail  : """
      Homemade focaccia, fresh mozzarella, tasty tomatoes (heirloom when available), drizzled with extra virgin olive oil.
      """
      category: "Side"    # [Starter|Side|Main|Dessert|Setting|Serving|Resource]
      pic     : Resty.lorempixel 200, 200, 'food'
      link    :   null
    1:
      title   : "Pizza al Radicchio"
      detail  : "Pizza with radicchio and olive oil"
      category: "Main"    # [Starter|Side|Main|Dessert|Setting|Serving|Resource]
      pic     : Resty.lorempixel 200, 200, 'food'
      link    :   null
    2:
      title   : "Pizza Diavola"
      detail  : """
      Pizza with pepperoni, buffalo mozzerella, red pepper flakes, and topped with fresh arugula
      """
      category: "Main"    # [Starter|Side|Main|Dessert|Setting|Serving|Resource]
      pic     : Resty.lorempixel 200, 200, 'food'
      link    :   null
    3:
      title   : "Tiramisu"
      detail  : "The best tiramusu ever!"
      category: "Dessert"    # [Starter|Side|Main|Dessert|Setting|Serving|Resource]
      pic     : Resty.lorempixel 200, 200, 'food'
      link    :   null
    4:
      title   : "Farm bird"
      detail  : "Grilled thigh with ginger & lime"
      category: "Main"    # [Starter|Side|Main|Dessert|Setting|Serving|Resource]
      pic     : Resty.lorempixel 200, 200, 'food'
      link    :   null
    5:
      title   : "Charred Lettuce"
      detail  : "Romaine, boquerones, chimichurri"
      category: "Side"    # [Starter|Side|Main|Dessert|Setting|Serving|Resource]
      pic     : Resty.lorempixel 200, 200, 'food'
      link    :   null
    6:
      title   : "Ribs"
      detail  : "Baby back, Chipotle, Cara Cara orange"
      category: "Main"    # [Starter|Side|Main|Dessert|Setting|Serving|Resource]
      pic     : Resty.lorempixel 200, 200, 'food'
      link    :   null
    7:
      title   : "Heirloom Tomatoes"
      detail  : "cucumber, radish salad, castelvetrano"
      category: "Side"    # [Starter|Side|Main|Dessert|Setting|Serving|Resource]
      pic     : Resty.lorempixel 200, 200, 'food'
      link    :   null
    8:
      title   : "Corn bread"
      detail  : "masa, smoked cheddar, jalepeno"
      category: "Side"    # [Starter|Side|Main|Dessert|Setting|Serving|Resource]
      pic     : Resty.lorempixel 200, 200, 'food'
      link    :   null
    9:
      title   : "Buttermilk Panna Cotta"
      detail  : "topped with grilled stone fruit salsa"
      category: "Dessert"    # [Starter|Side|Main|Dessert|Setting|Serving|Resource]
      pic     : Resty.lorempixel 200, 200, 'food'
      link    :   null
    10:
      title   : "Crab Chawanmushi"
      detail  : "Steamed egg custard with crab and herbs."
      category: "Small Plate"    # [Starter|Side|Small Plate|Main|Dessert|Setting|Serving|Resource]
      pic     : Resty.lorempixel 200, 200, 'food'
      link    :   null
    11:
      title   : "Tonkotsu Ramen"
      detail  : """
      A heaping bowl of our handmade ramen noodles in a rich, 48hr pork-bone broth.
      """
      category: "Main"    # [Starter|Side|Main|Dessert|Setting|Serving|Resource]
      pic     : Resty.lorempixel 200, 200, 'food'
      link    :   null
    12:
      title   : "Okonomiyaki"
      detail  : "Seafood pancake, cabbage, ginger, roasted seaweed, kewpie, tonkatsu sauce, bonito"
      category: "Small Plate"    # [Starter|Side|Main|Dessert|Setting|Serving|Resource]
      pic     : Resty.lorempixel 200, 200, 'food'
      link    :   null
    13:
      title   : "Grilled Shovelnose Guitarfish"
      detail  : """
      Grilled filet of Guitarfish served on grilled bok choy flavored with kimchi & sweet, savory soy infused daikon noodles. Topped with ume (pickled plums) hollandaise sauce.
      """
      category: "Small Plate"    # [Starter|Side|Main|Dessert|Setting|Serving|Resource]
      pic     : Resty.lorempixel 200, 200, 'food'
      link    :   null
    14:
      title   : "Miso Creme Brulee"
      detail  : "Saikyo miso, strawberries, shiso-honey"
      category: "Dessert"    # [Starter|Side|Main|Dessert|Setting|Serving|Resource]
      pic     : Resty.lorempixel 200, 200, 'food'
      link    :   null
    20:
      title   : "Barbecue Beef Brisket Texas Style"
      detail  : """
      Brisket is the national food of the Republic of Texas and a whole brisket is a great excuse for a party.
      A whole barbecue beef brisket is a huge clod of cow that can come off the pit almost black, looking more like a meteorite than a meal. But it is not burnt, and beneath the crust is the most tender, juicy, smoky meat.
      Join me as I try to replicate this recipe.
      """
      category: "Main"    # [Starter|Side|Main|Dessert|Setting|Serving|Resource]
      pic     : "http://amazingribs.com/images/beef/brisket_sandwich2.jpg"
      link    : "http://amazingribs.com/recipes/beef/texas_brisket.html"
    21:
      title   : "Disney-Style Smoked Turkey Legs"
      detail  : """
      Amusement parks and fairs have given smoked turkey legs a cult-like following,
      with some people offering money online for a recipe that mimics the legs sold at Disneyland.
      The secret is to soak the legs in brine for 24 hours, then smoke them low and slow. The flavor is ham-like, and very addictive.
      """
      category: "Main"    # [Starter|Side|Main|Dessert|Setting|Serving|Resource]
      pic     : "http://www.traegergrills.com/Content/images/recipes/turkey-legs.jpg"
      link    : "http://www.traegergrills.com/recipes/detail/82#.VeVUn9OqpBc"
      # http://amazingribs.com/recipes/chicken_turkey_duck/disney_smoked_turkey_legs.html
    22:
      title   : "Carolina Pulled Pork"
      detail  : """
      The sandwich — drizzled with a bit of the vinegary sauce, which cuts the richness of the meat — is the ultimate in Carolina barbecue.
      A "dry rub" of brown sugar, pepper, paprika and salt flavors the meat before it is cooked,
      and a vinegary "mop" is brushed onto the pork to add more taste as it is smoked.
      Once cooked, the meat is "pulled," that is, shredded into slivers that are just the right size for piling onto a bun.
      """
      category: "Main"    # [Starter|Side|Main|Dessert|Setting|Serving|Resource]
      pic     : "http://www.epicurious.com/images/recipesmenus/1999/1999_july/101803.jpg"
      link    : "http://www.epicurious.com/recipes/food/views/carolina-pulled-pork-sandwiches-101803g"
    23:
      title   : "Creamy Cole Slaw"
      detail  : """
      This coleslaw is AMAZING and is a far cry from the limp, sugary, slop that is on most menus.
      It pairs perfectly on top of a pulled pork sandwich or as a side dish with any other BBQ or picnic fare.
      """
      category: "Side"    # [Starter|Side|Main|Dessert|Setting|Serving|Resource]
      pic     : "http://img.sndimg.com/food/image/upload/w_555,h_416,c_fit,fl_progressive,q_95/v1/img/recipes/11/38/41/picVCNd5Q.jpg"
      link    : "http://www.epicurious.com/recipes/food/views/barbecue-turkey-burgers-with-creamy-cole-slaw-holden-13254"
    24:
      title   : "Grilled Corn with Chili Lime Butter"
      detail  : """
      Grilled corn is it essence of Summer - but Chili Lime makes it better!
      """
      category: "Side"    # [Starter|Side|Main|Dessert|Setting|Serving|Resource]
      pic     : "http://www.seriouseats.com/recipes/assets_c/2010/08/20100810-corn-with-chili-lime-butter-thumb-625xauto-105225.jpg"
      link    : "http://www.seriouseats.com/recipes/2010/08/grilling-corn-with-chili-lime-butter-recipe.html"
    25:
      title   : "бира от България"
      detail  : """
      Bring your favorite local beers (and wine)
      """
      category: "Drinks"    # [Starter|Side|Main|Dessert|Setting|Serving|Resource]
      pic     : "http://s3.amazonaws.com/foodspotting-ec2/reviews/3960046/thumb_600.jpg?1377190710"
      link    : ""
    26:
      title   : "Juices, Smoothies, & Soft Drinks "
      detail  : """
      And something for the деца
      """
      category: "Drinks"    # [Starter|Side|Main|Dessert|Setting|Serving|Resource]
      pic     : "http://www.h2o2.com/images/drinking-water.jpg"
      link    : ""

   


  }
  # coffeelint: enable=max_line_length
  # add id to lorempixel urls
  _.each data, (v,k)->
    v.pic += k % 10 if !v.pic
    return

  return service = new Resty(data)


MenuItemsResource.$inject = ['Resty','amMoment']

angular.module 'starter.core'
  .factory 'MenuItemsResource', MenuItemsResource