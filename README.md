Kleks - Pure CouchDB based CMS
==============================

**Kleks** is a pure CouchDB based CMS written as a **CouchApp** using Kanso, Spine.js, CoffeeScript and Stylus. Supports multi-site setup and Markdown authoring. It is fully open-source with a MIT license.

Kleks can be used to power a network of content-based sites with the ability to fully sync/replicate its NoSQL document-based datastore, CouchDB, in real-time to other locations. The admin interface is accessible from desktops and mobile tablets at this time.

It generates fully responsive websites that are optimized for mobile devices as well. The front-end is built as a CouchApp with HTML5/JavaScript that lives and is served from inside the CouchDB database. It means that there is no need for the middle-tier and no other servers are required.

It has been successfully deployed for a network of content-based sites on [Cloudant](http://cloudant.com) – a scalable hosted CouchDB cloud infrastructure – and replicates to multiple local and remote machines for backups and offline access.

## Who Should Use It?

Kleks is meant for moderate to experienced CouchDB developers that are interested in having a CouchApp solution for some of their content-based site deployments. They can use it as a starting point to customize their own solution for their clients.

## Philosophy

**Kleks** was born for the purpose of serving a network of content sites that are managed by the same entity and are considered to be, what I call living books. It revolves around essays that are contained in collections on each site which are served as a simple, mobile-first, and clean design with focus on the content itself. Each collection can be considered to be a book of essays around a theme/topic, and each essay is written around an idea which may have sections that will auto-create its Table of Contents.

The admin interface is a modern web application written as a CouchApp that has a fast and clean interface which is uncluttered and easy on the eye. It uses Markdown to compose and preview the content within for clean publishing of essays — the living content.

There is also the concept of content sponsorships to monetize these living collections and essays with the ability to place the sponsor's name, link, ad image or video on individual essays or collections of choice, or even just place some Google AdSense for monitization. But only a single sponsor per page to keep interface non-cluttered and reader friendly.

## Example Sites Using Kleks

Kleks was originally written for a network of sites listed below to migrate them from the common WordPress CMS, PHP, and MySQL to a completely CouchDB based solution without any other layers needed.

- [Evita Ochel](http://www.evitaochel.com) – Consciousness Expansion Teacher.
- [Evolving Wellness](http://www.evolvingwellness.com) – Holistic, Natural, and Green Approach to Optimal Wellness.
- [Evolving Beings](http://www.evolvingbeings.com) – Consciousness Expansion and Heart-Centered Living.
- [Evolving Channels](http://www.evolvingchannels.com) – Video Library for the Awakening Mind.
- [Evolving Scenes](http://www.evolvingscenes.com) – Reflections and Nature Photography.
- [Healthytarian](http://www.healthytarian.com) – Fresh Thinking. Smart Eating. Mindful Living.
- [Markuso Web Solutions](http://www.markuso.com) – Developing Holistic Modern Web Applications.

## Admin App Screeshots

Visit the [project site](http://markuso.github.io/kleks) to see some screenshots of the admin app.

## Development Technologies Used

Kleks uses few web development technologies to produce the final result of two CouchApps – one that renders the sites, and one that is the admin app to manage all content and sites.

[Kanso](http://kan.so/) – Can be described as the NPM for CouchApps. It is the best way to create and share CouchApps on CouchDB.

[Spine.js](http://spinejs.com/) – Build Awesome JavaScript MVC Applications. It is similar and inspired by Backbone.js but written in CoffeeScript.

[CoffeeScript](http://coffeescript.org) – A little clean language that compiles into JavaScript.

[Stylus](http://learnboost.github.io/stylus/) – Expressive, dynamic, robust CSS.

## Setup & Deployment

The best way to ask a question about deployment, or to report an issue, is to use the GitHub [issues](https://github.com/markuso/kleks/issues) section of the main GitHub repository. There is still more to document in the [wiki](https://github.com/markuso/kleks/wiki) soon to understand the features better.

You will need to use [Kanso](http://kan.so/) for managing the CouchApp's packages, build, and deployment. It makes it super easy to manage. To [install Kanso](http://kan.so/install), just use NPM as follows given that you have NPM and Node.js already installed:

    $ sudo npm install -g kanso

In Kanso, Node.js is used for the command-line tools only. The end result is a pure CouchApp you can host using CouchDB alone. Learn more at [Kanso](http://kan.so/).

### Deploy To CouchDB (local or cloud)

For new setup only, begin with installing dependencies as follows:

    $ cd ~/path/to/kleks/admin
    $ kanso install

    $ cd ~/path/to/kleks/site
    $ kanso install

Push the current app (for each app folder `/site` and `/admin`) to development CouchDB:

    $ kanso push

Once a `.kansorc` file is created (see below) with a production config setting named `live` then we can deploy to prodcution using:

    $ kanso push live

Or you can even push to any arbitrary distination if you like:

    $ kanso push http://url.of.your-couch-server.com

### Example `.kansorc` File

You should create a `.kansorc` like the example below. The example assumes your database is name `kleks` but it could be anything you want, and for your live database it assumes you are hosting it on [Cloudant](http://cloudant.com). Be sure to modify by providing your information instead. This file should stay private and is ignored in `.gitignore` so to not commit it to Git.

    exports.env = {
      'default': {
        db: 'http://user:password@localhost:5984/kleks'
      },
      'live': {
        db: 'https://user:password@username.cloudant.com/kleks',
        baseURL: '/.',
        minify: true
      }
    };

Please note that the `baseURL: '/.'` is needed when deploying a Kanso CouchApp to [Cloudant](http://cloudant.com) so file references, like js and css files, can work properly.

You will need the same `.kansorc` file in both locations, `.../kleks/admin` and `.../kleks/site` so that when you use `kanso push` or `kanso push live` you will be pushing to correct database on your CouchDB (local or cloud).

You can of course add more deployment destinations beyond the `default` and `live` destinations you see above. Refer to [Kanso documentation](http://kan.so/docs/Configuration_.kansorc) on this for more info.

## TODO
 
- Deal with large data sets rendering
- Write as many tests as possible
- Documentation of the whole app

## MIT License

(The MIT License)

Copyright (C) 2012 by Markus Ochel <markus@markuso.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
