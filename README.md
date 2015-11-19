Kleks - Pure CouchDB based CMS
==============================

**Kleks** is a pure CouchDB based CMS written as a **CouchApp** using Kanso, Spine.js, CoffeeScript and Stylus. Supports multi-site setup and Markdown authoring. It is fully open-source with a MIT license.

Kleks can be used to power a network of content-based sites with the ability to fully sync/replicate its NoSQL document-based datastore, CouchDB, in real-time to other locations. The admin interface is accessible from desktops and mobile tablets at this time.

It generates fully responsive websites that are optimized for mobile devices as well. The front-end is built as a CouchApp with HTML5/JavaScript that lives and is served from inside the CouchDB database. It means that there is no need for the middle-tier and no other servers are required.

It has been successfully deployed for a network of content-based sites on [Cloudant](http://cloudant.com) – a scalable hosted CouchDB cloud infrastructure with search features – and replicates to multiple local and remote machines for backups and offline access.

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

## Quick Install - Replicate a fresh database

A fresh and ready copy of Kleks' design documents are pushed to a database named `kleks_install` on Cloudant. So to get your hands wet, just replicate that database from `https://markuso.cloudant.com/kleks_install` to your local CouchDB or any cloud service you have.

You can replicate using Futon from your CouchDB instance, or use the command line `curl` tool to do so:

    $ curl http://localhost:5984/_replicate -H 'Content-Type: application/json' -d '{ "source": "https://markuso.cloudant.com/kleks_install", "target": "kleks" }'

## VHOSTS are a MUST

After you install Kleks and its design documents into your database, you must create a virtual host to point to the `_design/admin` CouchApp, and one for every site you create there after to point to a specific path using the `_design/site` CouchApp.

This is important for many reasons inside Kleks, so it must be done. On your local CouchDB, you can do this easily in **Futon > Configuration > vhosts** section.

If you are working locally, be sure to also have these custom host domains listed in your `/etc/hosts` file as an alias to `127.0.0.1`. For production domains, be sure to point your chosen domains using a CNAME to your CouchDB hosting account, like `USERNAME.cloudant.com`.

The admin interface to Kleks should be configured with a virtual host domain of your choice and always pointing to `/DATABASE/_design/admin/_rewrite`.

Each site has a unique `_id` which should be set as its full domain name. Like `www.exmaple.com` or `subsite.mydomain.com`, etc. Given that, each site must have an entry in your `vhosts` CouchDB configuration in the format of `/DATABASE/_design/site/_rewrite/render/<site_id>` – again usually the database is named `kleks` (but might not if you have multiple DBs running Kleks) and the site_id is the domain name.

For example:

    vhosts:
      kleks.example.local = /kleks/_design/admin/_rewrite
      www.example.local   = /kleks/_design/site/_rewrite/render/www.example.com

If your local CouchDB install is still running on the default port `5984` then you can access the admin app above at `http://kleks.example.local:5984` and so on. I am running my CouchDB on port 80, so I don't need to use the port number.

On Cloudant, you do the above using their control panel for your account. You will find an option to setup the above under a tab called Virtual Hosts. Make sure to use real domains that you have already changed the DNS for them with a CNAME to point to your Cloudant account similar to `USERNAME.cloudant.com`.

Other CouchDB hosting providers may use Futon to allow you to do this, or their own control panel.

## User Permissions

Your Kleks database must be setup to be read by anyone so the public can view and navigate your sites. For your admin app, a user or more must be created in your CouchDB `_users` database and give the role `manager` or `admin` for them to be able to log in. This is usually done using Futon.

Also, make sure that you update your database security roles for **Admins** to state `["admin","manager"]` as the roles.

### On Cloudant

You can use Cloudant's authentication to login to the admin app. Just make sure a Cloudant's user or generated API Key has either the _create_ or _admin_ permission.

But if you want to create and use a `_users` database to manage access to the admin app, then you must first turn off Cloudant's own security for the Kleks database to manage via `_users`. To do this you need to PUT a JSON document like the following to the `_security` endpoint of the database (for example `https://USERNAME.cloudant.com/DATABASE/_security`):

    {
      "cloudant": { "nobody": ["_reader","_creator","_writer","_admin"] },
      "readers": { "names": [], "roles": [] },
      "admins": { "names": [], "roles": ["admin","manager"] }
    }

You can achieve that by using the following: _(be sure to change the USERNAME and DATABASE where needed below)_

    $ curl -X PUT -u USERNAME -p https://USERNAME.cloudant.com/DATABASE/_security -d '{"cloudant":{"nobody":["_reader","_creator","_writer","_admin"]}, "readers": {"names": [], "roles": []}, "admins": {"names": [], "roles": ["admin","manager"]}}'

See their own [security documentation](https://cloudant.com/for-developers/faq/auth/) for more details.


## Self Setup & Deployment

This is the approach you will mostly take to customize Kleks to your needs and push its design documents, the CouchApps, to your CouchDB.

The best way to ask a question about deployment, or to report an issue, is to use the GitHub [issues](https://github.com/markuso/kleks/issues) section of the main GitHub repository. There is still more to document in the [wiki](https://github.com/markuso/kleks/wiki) soon to understand the features better.

You will need to use [Kanso](http://kan.so/) for managing the CouchApp's packages, build, and deployment. It makes it super easy to manage. To [install Kanso](http://kan.so/install), just use NPM as follows given that you have NPM and Node.js already installed:

    $ sudo npm install -g kanso

In Kanso, Node.js is used for the command-line tools only. The end result is a pure CouchApp you can host using CouchDB alone. Learn more at [Kanso](http://kan.so/).

Now download or clone the Kleks git repo. You can always get a copy of the latest master branch by using:

    $ git clone https://github.com/markuso/kleks.git

That will download and create a folder in your current path named `kleks`. You may change the folder name as you wish.

### Deploy To CouchDB (local or cloud)

Kleks has two CouchApps that need to be pushed to your CouchDB. One is `_design/admin` for the management of content and sites, and one is `_design/site` which renders sites according to their configurations and domain for the world to see.

When you first setup Kleks, begin with installing dependencies for each CouchApp and pushing to your destination as follows: _(assuming your folder is left named `kleks`)_

    $ cd ~/path/to/kleks/admin
    $ kanso install
    $ kanso push

    $ cd ~/path/to/kleks/site
    $ kanso install
    $ kanso push

Once a `.kansorc` file is created (see below) with a production config setting named `live` then we can deploy to prodcution using:

    $ cd ~/path/to/kleks/admin
    $ kanso push live

    $ cd ~/path/to/kleks/site
    $ kanso push live

Or you can even push to any arbitrary distination if you like:

    $ kanso push http://your-couch-server.com/dbname

### Example `.kansorc` File

You should create a `.kansorc` like the example below. The example assumes your database is name `kleks` but it could be anything you want, and for your live database it assumes you are hosting it on [Cloudant](http://cloudant.com). Be sure to modify by providing your information instead. This file should stay private and is ignored in `.gitignore` so to not commit it to Git.

    exports.env = {
      'default': {
        db: 'http://user:password@localhost:5984/kleks'
      },
      'live': {
        db: 'https://user:password@USERNAME.cloudant.com/kleks',
        baseURL: '/.',
        minify: true
      }
    };

Please note that the `baseURL: '/.'` is needed when deploying a Kanso CouchApp to [Cloudant](http://cloudant.com) so file references, like js and css files, can work properly.

You will need the same `.kansorc` file in both locations, `.../kleks/admin` and `.../kleks/site` so that when you use `kanso push` or `kanso push live` you will be pushing to correct database on your CouchDB (local or cloud).

You can of course add more deployment destinations beyond the `default` and `live` destinations you see above. Refer to [Kanso documentation](http://kan.so/docs/Configuration_.kansorc) on this for more info.

## How To Use Kleks

There is still more to document in the [wiki](https://github.com/markuso/kleks/wiki) soon to understand all the features of Kleks better. There are some features that are hidden and do need documentation to benefit from them until they become part of the UI and easily used.

The [wiki](https://github.com/markuso/kleks/wiki) will be the next order of focus to create a User Manual essentially.

## TODO
 
- Deal with large data sets rendering
- Write as many tests as possible
- Documentation of all the features of Kleks
- Possibly rewrite the admin app using AngularJS framework

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
