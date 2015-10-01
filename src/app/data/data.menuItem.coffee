'use strict'

MenuItemsResource = (Resty, amMoment) ->
  # Event hasMany MenuItems
  className = 'MenuItems'
  # coffeelint: disable=max_line_length
  data = {
    0:
      title   : "Foccacia with Tomatoes"
      detail  : """
      Homemade focaccia, fresh mozzarella, tasty tomatoes (heirloom when available), drizzled with extra virgin olive oil.
      """
      category: "Side"    # [Starter|Side|Main|SmallPlate|Dessert|Setting|Serving|Resource]
      pic     : "http://graphics8.nytimes.com/images/2013/05/14/science/14recipehealth/14recipehealth-articleLarge.jpg"
      link    :   null
    1:
      title   : "Pizza al Radicchio"
      detail  : "Pizza with radicchio and olive oil"
      category: "Main"    # [Starter|Side|Main|SmallPlate|Dessert|Setting|Serving|Resource]
      pic     : "http://slice.seriouseats.com/images/20111208-basil-duo.jpg"
      link    :   null
    2:
      title   : "Pizza Diavola"
      detail  : """
      Pizza with pepperoni, buffalo mozzerella, red pepper flakes, and topped with fresh arugula
      """
      category: "Main"    # [Starter|Side|Main|SmallPlate|Dessert|Setting|Serving|Resource]
      pic     : "http://www.scattidigusto.it/wp-content/uploads/2010/10/Sorbillo-Napoli-margherita-dop.jpg"
      link    :   null
    3:
      title   : "Tiramisu"
      detail  : "The best tiramusu ever!"
      category: "Dessert"    # [Starter|Side|Main|SmallPlate|Dessert|Setting|Serving|Resource]
      pic     : "http://ichef.bbci.co.uk/food/ic/food_16x9_448/recipes/tiramisu_cake_13686_16x9.jpg"
      link    :   null
    4:
      title   : "Farm bird"
      detail  : "Grilled thigh with ginger & lime"
      category: "Main"    # [Starter|Side|Main|SmallPlate|Dessert|Setting|Serving|Resource]
      pic     : "http://www.traegergrills.com/teamtraeger/image.axd?picture=2014%2F7%2F8+plated+tequila+chicken.jpg"
      link    :   null
    5:
      title   : "Charred Lettuce"
      detail  : "Romaine, boquerones, chimichurri"
      category: "Side"    # [Starter|Side|Main|SmallPlate|Dessert|Setting|Serving|Resource]
      pic     : "http://blog.fatfreevegan.com/images/grilled-romaine.jpg"
      link    :   null
    6:
      title   : "Ribs"
      detail  : "Baby back, Chipotle, Cara Cara orange"
      category: "Main"    # [Starter|Side|Main|SmallPlate|Dessert|Setting|Serving|Resource]
      pic     : "http://static.guim.co.uk/sys-images/Guardian/Pix/pictures/2010/7/1/1277983151355/Spare-ribs-006.jpg"
      link    :   null
    7:
      title   : "Heirloom Tomatoes"
      detail  : "cucumber, radish salad, castelvetrano"
      category: "Side"    # [Starter|Side|Main|SmallPlate|Dessert|Setting|Serving|Resource]
      pic     : "http://honestfare.com/wp-content/uploads/2011/01/tanjelo-avocado-salad-3-honestfare.com-1.jpg"
      link    :   null
    8:
      title   : "Corn bread"
      detail  : "masa, smoked cheddar, jalepeno"
      category: "Side"    # [Starter|Side|Main|SmallPlate|Dessert|Setting|Serving|Resource]
      pic     : "http://w2.fnstatic.co.uk/sites/default/files/styles/recipe_main_pic/public/jalapeno-cornbread.jpg?itok=BmVY_xtx"
      link    :   null
    9:
      title   : "Buttermilk Panna Cotta"
      detail  : "topped with grilled stone fruit salsa"
      category: "Dessert"    # [Starter|Side|Main|SmallPlate|Dessert|Setting|Serving|Resource]
      pic     : Resty.lorempixel 200, 200, 'food'
      link    :   null
    10:
      title   : "Crab Chawanmushi"
      detail  : "Steamed egg custard with crab and herbs."
      category: "SmallPlate"    # [Starter|Side|Small Plate|Main|Dessert|Setting|Serving|Resource]
      pic     : Resty.lorempixel 200, 200, 'food'
      link    :   null
    11:
      title   : "Tonkotsu Ramen"
      detail  : """
      A heaping bowl of our handmade ramen noodles in a rich, 48hr pork-bone broth.
      """
      category: "Main"    # [Starter|Side|Main|SmallPlate|Dessert|Setting|Serving|Resource]
      pic     : "http://danielfooddiary.com/wp-content/uploads/2013/09/ippudosg3.jpg"
      link    :   null
    12:
      title   : "Okonomiyaki"
      detail  : "Seafood pancake, cabbage, ginger, roasted seaweed, kewpie, tonkatsu sauce, bonito"
      category: "SmallPlate"    # [Starter|Side|Main|SmallPlate|Dessert|Setting|Serving|Resource]
      pic     : Resty.lorempixel 200, 200, 'food'
      link    :   null
    13:
      title   : "Grilled Shovelnose Guitarfish"
      detail  : """
      Grilled filet of Guitarfish served on grilled bok choy flavored with kimchi & sweet, savory soy infused daikon noodles. Topped with ume (pickled plums) hollandaise sauce.
      """
      category: "SmallPlate"    # [Starter|Side|Main|SmallPlate|Dessert|Setting|Serving|Resource]
      pic     : Resty.lorempixel 200, 200, 'food'
      link    :   null
    14:
      title   : "Miso Creme Brulee"
      detail  : "Saikyo miso, strawberries, shiso-honey"
      category: "Dessert"    # [Starter|Side|Main|SmallPlate|Dessert|Setting|Serving|Resource]
      pic     : "http://foodnetwork.sndimg.com/content/dam/images/food/fullset/2009/11/4/0/FNM_120109-Try-This-At-Home-040_s4x3.jpg.rend.sni12col.landscape.jpeg"
      link    :   null
    20:
      title   : "Barbecue Beef Brisket Texas Style"
      detail  : """
      Brisket is the national food of the Republic of Texas and a whole brisket is a great excuse for a party.
      A whole barbecue beef brisket is a huge clod of cow that can come off the pit almost black, looking more like a meteorite than a meal. But it is not burnt, and beneath the crust is the most tender, juicy, smoky meat.
      Join me as I try to replicate this recipe.
      """
      category: "Main"    # [Starter|Side|Main|SmallPlate|Dessert|Setting|Serving|Resource]
      pic     : "http://amazingribs.com/images/beef/brisket_sandwich2.jpg"
      link    : "http://amazingribs.com/recipes/beef/texas_brisket.html"
    21:
      title   : "Disney-Style Smoked Turkey Legs"
      detail  : """
      Amusement parks and fairs have given smoked turkey legs a cult-like following,
      with some people offering money online for a recipe that mimics the legs sold at Disneyland.
      The secret is to soak the legs in brine for 24 hours, then smoke them low and slow. The flavor is ham-like, and very addictive.
      """
      category: "Main"    # [Starter|Side|Main|SmallPlate|Dessert|Setting|Serving|Resource]
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
      category: "Main"    # [Starter|Side|Main|SmallPlate|Dessert|Setting|Serving|Resource]
      pic     : "http://www.epicurious.com/images/recipesmenus/1999/1999_july/101803.jpg"
      link    : "http://www.epicurious.com/recipes/food/views/carolina-pulled-pork-sandwiches-101803"
    23:
      title   : "Creamy Cole Slaw"
      detail  : """
      This coleslaw is AMAZING and is a far cry from the limp, sugary, slop that is on most menus.
      It pairs perfectly on top of a pulled pork sandwich or as a side dish with any other BBQ or picnic fare.
      """
      category: "Side"    # [Starter|Side|Main|SmallPlate|Dessert|Setting|Serving|Resource]
      pic     : "http://img.sndimg.com/food/image/upload/w_555,h_416,c_fit,fl_progressive,q_95/v1/img/recipes/11/38/41/picVCNd5Q.jpg"
      link    : "http://www.epicurious.com/recipes/food/views/barbecue-turkey-burgers-with-creamy-cole-slaw-holden-13254"
    24:
      title   : "Grilled Corn with Chili Lime Butter"
      detail  : """
      Grilled corn is it essence of Summer - but Chili Lime makes it better!
      """
      category: "Side"    # [Starter|Side|Main|SmallPlate|Dessert|Setting|Serving|Resource]
      pic     : "http://www.seriouseats.com/recipes/assets_c/2010/08/20100810-corn-with-chili-lime-butter-thumb-625xauto-105225.jpg"
      link    : "http://www.seriouseats.com/recipes/2010/08/grilling-corn-with-chili-lime-butter-recipe.html"
    25:
      title   : "бира от България"
      detail  : """
      Bring your favorite local beers
      """
      category: "Drinks"    # [Starter|Side|Main|SmallPlate|Dessert|Setting|Serving|Resource]
      pic     : "http://s3.amazonaws.com/foodspotting-ec2/reviews/3960046/thumb_600.jpg?1377190710"
      link    : ""
    26:
      title   : "вино от България"
      detail  : """
      Bring your favorite local wines
      """
      category: "Drinks"    # [Starter|Side|Main|SmallPlate|Dessert|Setting|Serving|Resource]
      pic     : "https://thewinecountry.com/twcwp/wp-content/uploads/2014/03/Wine.jpg"
      link    : ""
    27:
      title   : "Juices, Smoothies, & Soft Drinks "
      detail  : """
      And something for the деца
      """
      category: "Drinks"    # [Starter|Side|Main|SmallPlate|Dessert|Setting|Serving|Resource]
      pic     : "http://www.h2o2.com/images/drinking-water.jpg"
      link    : ""
    28:
      title   : "The Best Barbecue Beans"
      detail  : """
      For the absolute best barbecue beans, it's hard to beat the deep flavor of dried beans slowly cooked in sauce for many hours.
      """
      category: "Side"    # [Starter|Side|Main|SmallPlate|Dessert|Setting|Serving|Resource]
      pic     : "http://www.seriouseats.com/recipes/assets_c/2014/05/20140530-294420-best-bbq-beans-thumb-625xauto-404009.jpg"
      link    : "http://www.seriouseats.com/recipes/2014/06/best-barbecue-beans-recipe.html"
    29:
      title   : "Watermelon"
      detail  : """
      """
      category: "Dessert"    # [Starter|Side|Main|SmallPlate|Dessert|Setting|Serving|Resource]
      pic     : "http://www.time2saveworkshops.com/wp-content/uploads/2012/08/watermelon.jpg"
      link    : null
    30:
      title   : "Best Buffalo Wings Ever"
      detail  :"""
      Buffalo wings are pure, unadulterated, crispy, greasy, hot and vinegary nuggets of awesome.
      Whether you believe the apocryphal (or at least wildly inaccurate) account of their creation as an impromptu late-night snack at the Anchor Bar in Buffalo New York,
      or the equally apocryphal story Calvin Trillin tells of a John Young and his "wings in mambo sauce,"
      there's one thing that we can all believe:
      you will be eating Buffalo wings this coming Saturday!
      """
      category: "Main"
      pic     : "http://www.seriouseats.com/images/2015/04/20150428-buffalo-wings-reupload-kenji-6.jpg"
      link    : "http://www.seriouseats.com/2012/01/the-food-lab-how-to-make-best-buffalo-wings-fry-again-ultimate-crispy-deep-fried-buffalo-wings.html"
    35:
      title   : "IPAs for all"
      detail  : """
      Only 'Indian' Pale Ales today
      """
      category: "Drink"    # [Starter|Side|Main|SmallPlate|Dessert|Drink|Setting|Serving|Resource]
      pic     : "http://drinks.seriouseats.com/images/20110512neIPAprimary.jpg"
      link    : ""
    36:
      title   : "Chardonnay"
      detail  : """
      Bring a favorite bottle of Chardonnay to share. Sally is counting on you...
      """
      category: "Drink"    # [Starter|Side|Main|SmallPlate|Dessert|Drink||Setting|Serving|Resource]
      pic     : "https://thewinecountry.com/twcwp/wp-content/uploads/2014/03/Wine.jpg"
      link    : ""


  }
  # coffeelint: enable=max_line_length
  # add id to lorempixel urls
  _.each data, (v,k)->
    v.pic += k % 10 if /lorempixel/.test v.pic
    return

  service = new Resty(data, className)

  #
  # additional MenuItemsResource Class Methods
  #
  _sortOrder = {
    "category":
      Starter   : 10
      Side      : 20
      Main      : 30
      SmallPlate: 40
      Drinks    : 45
      Dessert   : 50
      Setting   : 60
      Serving   : 70
      Resource  : 80
  }
  _labels = {
    Starter   : 'Starters'
    Side      : 'Sides'
    Main      : 'Mains'
    SmallPlate: 'Small Plates'
    Dessert   : 'Desserts'
    Drink     : "Drinks"
    Setting   : 'Settings'
    Serving   : 'Serving Utentils'
    Resource  : 'Resources'
  }

  service.sortByCategory = (data)->
    data = this._data if `data==null`
    data = _.sortBy data, 'title'
    return _.sortBy data, (o)-> return _sortOrder['category'][ o['category'] ]

  service.getCategoryLabel = (menuItem)->
    cat =
      if angular.isString menuItem
      then menuItem
      else menuItem.category
    return _labels[cat]

  service.categoryLookup = _labels

  return service




MenuItemsResource.$inject = ['Resty','amMoment']

angular.module 'starter.core'
  .factory 'MenuItemsResource', MenuItemsResource