# pluckie 
An app for elevating potlucks and community meals around the world.

## installation
```
git clone https://github.com/mixersoft/pluckie.git [folder]
cd [folder]
mkdir www
ionic lib update
bower install
npm install 
# if you need to run as administrator, use `sudo npm install`

# To continue dev in a new git repo 
git remote rename origin seed 
git remote add origin [github repo]
git push -u origin master


# install Cordova plugins from web
ionic plugin add cordova-plugin-console
ionic plugin add com.ionic.keyboard
ionic plugin add cordova-plugin-device
ionic plugin add cordova-plugin-media
ionic plugin add cordova-plugin-file
ionic plugin add cordova-plugin-splashscreen
ionic plugin add https://github.com/phonegap-build/PushPlugin
ionic plugin add https://github.com/katzer/cordova-plugin-local-notifications
ionic plugin add https://git-wip-us.apache.org/repos/asf/cordova-plugin-inappbrowser
ionic plugin add https://github.com/driftyco/ionic-plugins-deploy


# add Cordova platforms
# note: this project has only been tested on iOS 
ionic platform add ios
```



# Based on ionic-tabs-starter-sass-jade-coffee

Ionic tabbed view starter project implemented with Sass, Jade and CoffeeScript.

The original project in JavaScript was done by [benevolentprof](https://github.com/benevolentprof "benevolentprof") @ [ionic-tabs-starter-angular-style](https://github.com/benevolentprof/ionic-tabs-starter-angular-style "ionic-tabs-starter-angular-style"),
an Ionic tabbed view starter project refactored according to the Angular Style Guide.

## Features

- Gulp jobs for development and building.
- Compiles your Sass, Jade and CoffeeScript.
- CoffeeScript and Sass lints.
- Local development server with live reload.
- Automatically injects JavaScript and CSS files into `index.html`.
- Follows the [Angular Style Guide](https://github.com/johnpapa/angular-styleguide "Angular Style Guide")

## Installing

Follow point 1 of [Ionic](http://ionicframework.com/getting-started/ "Getting Started with Ionic"). Then clone the project and install dependencies.

```bash
$ npm install -g cordova ionic gulp
$ git clone https://github.com/dpramar/ionic-tabs-starter-sass-jade-coffee.git <FOLDER>
$ npm install
```

For development purposes and to be able to lint your `.scss` files, it is required to install Ruby and [scss-lint](https://github.com/brigade/scss-lint "scss-lint")

```bash
$ gem install scss_lint
```

## Gulp integration

ionic-tabs-starter-sass-jade-coffee uses gulp (`npm install -g gulp`) to compile the source files and gets the vendor dependencies from bower.
Add the source folder of any extra dependency to `vendor.json` array to inject them into `index.html`.

__flags/options:__

    [--production|-p] ..... Injects minified version of vendor files and minifies css and javascript.

### Tasks

Build the `src/app/` folder into `www`.

```bash
$ gulp build [options]
```

Build and open the app in a browser. It will also watch for changes and reload the browser.

```bash
$ gulp dev [options]
```

Clean the `www` folder.

```bash
$ gulp clean
```

## Starting the app in a browser

Only gulp:

```bash
$ gulp dev
```

With ionic:

```bash
$ gulp build
$ ionic serve
```

## Improvements and issues

Feel free to collaborate creating a pull request or reporting an issue.


# License
(c) Snaphappi, Inc. 2015, All Rights Reserved.