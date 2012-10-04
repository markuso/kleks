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

Temp Stuff
----------

  select ID, post_date_gmt, post_content, post_title, post_modified_gmt, post_name, post_author, guid from wp_posts where post_type = 'post' and post_status = 'publish'


  select "www.evolvingwellness.com" as site, "essay" as type, post_date_gmt as published_at, post_content as body, post_title as title, post_modified_gmt as updated_at, post_name as slug, case post_author when 2 then "2d9a5976ee3b7d7130154b708e03a517" else post_author end as author_id, ID as old_id, post_name as old_slug, guid as old_url from wp_posts where post_type = 'post' and post_status = 'publish' limit 10

  kanso transform csv --indent=2 query_result.csv query_result.json

  kanso transform add-ids -u http://localhost:80 query_result.json query_result_ids.json

  kanso transform map --module=map.js query_result_ids.json query_result_final.json

  kanso upload query_result_final.json


{
   "_id": "92655f6a1695d5c822d3c794e50074a5",
   "site": "www.evolvingwellness.com",
   "slug": "",
   "title": "",
   "intro": "",
   "body": "",
   "photo": "",
   "published": true,
   "published_at": "2012-08-20T18:30:00.000Z",
   "updated_at": "2012-09-27T23:15:41.134Z",
   "author_id": "56a80424639f9e4f5353bd01e20637c9",
   "collections": [],
   "type": "essay",
   "_attachments": {}
}

Evolving Wellness = 569 docs
Evolving Beings = 497 docs
Evolving Scenes = 580 docs
Healthytarian = 22 docs
