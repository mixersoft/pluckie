'use strict'

MenuItemsResource = (Resty, amMoment) ->
  # Event hasMany MenuItems
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

  }

  # add id to lorempixel urls
  _.each data, (v,k)->
    v.pic += k % 10
    return

  return service = new Resty(data)


MenuItemsResource.$inject = ['Resty','amMoment']

angular.module 'starter.core'
  .factory 'MenuItemsResource', MenuItemsResource