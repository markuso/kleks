Setup
-----

For new setup, begin with installing dependencies as follows:

    $ cd ~/CouchApps/kleks/admin
    $ kanso install
    $ cd ~/CouchApps/kleks/site
    $ kanso install

Push the current app (site or admin) to development CouchDB

    $ kanso push

Once configure a `.kansorc` file with a production config named `live`

    $ kanso push live

Fonts
-----

**Google Fonts URL** for some review fonts:

    http://www.google.com/webfonts#ReviewPlace:refine/Collection:Dosis:200,400,700|Lato:300,400,700|Droid+Serif:400,700,400italic,700italic

In CSS `.styl` file we are using the _Lato_ font:

    @import url('http://fonts.googleapis.com/css?family=Lato:300,400,700')

    body
      font-family: 'Lato', 'Helvetica Neue', Helvetica, Arial, sans-serif
      font-weight: 300
      font-size: 16px
      letter-spacing: 0em
      word-spacing: 0.2em
      line-height: 1.5em

Main Photos
-----------

Dimension must be **900 x 180** pixels saved as JPG at _70%_ or a PNG with trying to keep file size below 50K.


Donation URL
------------

    https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=N62XWCYGBQRQY
