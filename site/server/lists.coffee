templates = require('duality/templates')
dutils    = require('duality/utils')
settings  = require('settings/root')
Showdown  = require('showdown')
_         = require('underscore')._
utils     = require('lib/utils')
moment    = require('lib/moment')


exports.home = (head, req) ->
  # no need for double render on first hit
  return if req.client and req.initial_hit
  start code: 200, headers: {'Content-Type': 'text/html'}

  md = new Showdown.converter()
  collections = []
  blocks = {}
  site = {}

  while row = getRow()
    doc = row.value
    if doc
      collections.push(doc) if doc.type is 'collection'
      blocks[doc.code] = doc if doc.type is 'block'
      site = doc if doc.type is 'site'
  
  collections = _.map collections, (doc) ->
    if doc.intro?
      doc.intro_html = md.makeHtml(
        doc.intro.replace(/\{\{?baseURL\}?\}/g, dutils.getBaseURL(req))
      )
    doc.updated_at_html = utils.prettyDate(doc.updated_at)
    doc.updated_at_half = utils.halfDate(doc.updated_at)
    doc.fresh = utils.isItFresh(doc.updated_at)
    doc.type_tc = utils.capitalize(doc.type)
    return doc

  return {
    on_dev: utils.isDev(req)
    site: site
    title: "#{site.name}"
    content: templates.render "home.html", req,
      collections: collections
      blocks: blocks
      nav: 'home'
    og:
      site_name: site.name
      title: site.name
      description: site.seo_description
      type: 'website'
      url: site.link
      image: "#{site.link}/file/#{blocks.site_intro._id}/#{blocks.site_intro.photo}" if blocks.site_intro?.photo
  }


exports.collection = (head, req) ->
  # no need for double render on first hit
  return if req.client and req.initial_hit
  start code: 200, headers: {'Content-Type': 'text/html'}

  md = new Showdown.converter()
  docs = []
  collection = null
  blocks = {}
  sponsor = null
  site = {}

  while row = getRow()
    doc = row.doc
    if doc
      docs.push(doc) if doc.type in settings.app.content_types
      collection ?= doc if doc.type is 'collection'
      blocks[doc.code] = doc if doc.type is 'block'
      sponsor ?= doc if doc.type is 'sponsor'
      site = doc if doc.type is 'site'

  if collection
    if collection.intro?
      collection.intro_html = md.makeHtml(
        collection.intro.replace(/\{\{?baseURL\}?\}/g, dutils.getBaseURL(req))
      )
    collection.fresh = utils.isItFresh(collection.updated_at)
    collection.type_tc = utils.capitalize(collection.type)

  docs = _.map docs, (doc) ->
    if doc.intro?
      doc.intro_html = md.makeHtml(
        doc.intro.replace(/\{\{?baseURL\}?\}/g, dutils.getBaseURL(req))
      )
    doc.published_at_html = utils.prettyDate(doc.published_at)
    doc.fresh = utils.isItFresh(doc.published_at)
    doc.type_tc = utils.capitalize(doc.type)
    if doc.type is 'scene'
      doc.list_item_template = 'partials/list-item-scene.html'
    else
      doc.list_item_template = 'partials/list-item-default.html'
    return doc

  if sponsor
    # Check for strat/end dates of sponsorship
    sponsor_start = moment.utc(collection.sponsor_start)
    sponsor_end = moment.utc(collection.sponsor_end)
    now = moment.utc()
    if sponsor_start.diff(now) <= 0 and sponsor_end.diff(now) >= 0
      # let's continue on
      sponsor.text_format = sponsor.format is 'text'
      sponsor.image_format = sponsor.format is 'image'
      sponsor.video_format = sponsor.format is 'video'
      sponsor.embed_format = sponsor.format is 'embed'
      sponsor.for_type = collection.type
      sponsor.for_type_tc = collection.type_tc
    else
      # let's remove the sponsor
      sponsor = null

  if collection
    return {
      on_dev: utils.isDev(req)
      site: site
      title: collection.name
      content: templates.render 'collection.html', req,
        collection: collection
        docs: docs
        sponsor: sponsor
        blocks: blocks
        nav: 'collection'
      og:
        site_name: site.name
        title: collection.name
        description: collection.intro
        type: 'website'
        image: "#{site.link}/file/#{collection._id}/#{collection.photo}" if collection.photo
    }
  else
    return {
      code: 404
      title: '404 Not Found'
      content: templates.render '404.html', req, { host: req.headers.Host }
      on_dev: utils.isDev(req)
    }


exports.docs = (head, req) ->
  # no need for double render on first hit
  return if req.client and req.initial_hit
  start code: 200, headers: {'Content-Type': 'text/html'}

  md = new Showdown.converter()
  docs = []
  site = {}

  while row = getRow()
    doc = row.doc
    if doc
      if doc.type in settings.app.content_types
        doc.collection_docs = []
        docs.push(doc)
      else if doc.type is 'collection'
        # Add the collection doc to the last doc pushed
        docs[docs.length-1].collection_docs.push(doc)
      site = doc if doc.type is 'site'

  docs = _.map docs, (doc) ->
    if doc.intro?
      doc.intro_html = md.makeHtml(
        doc.intro.replace(/\{\{?baseURL\}?\}/g, dutils.getBaseURL(req))
      )
    doc.published_at_html = utils.prettyDate(doc.published_at)
    doc.updated_at_html = utils.prettyDate(doc.updated_at)
    doc.fresh = utils.isItFresh(doc.published_at)
    doc.type_tc = utils.capitalize(doc.type)
    if doc.type is 'scene'
      doc.list_item_template = 'partials/list-item-scene.html'
    else
      doc.list_item_template = 'partials/list-item-default.html'
    return doc

  return {
    on_dev: utils.isDev(req)
    site: site
    title: 'Docs List'
    content: templates.render 'docs.html', req,
      docs: docs
      nav: 'docs'
    og:
      site_name: site.name
      title: site.name
      description: site.seo_description
      type: 'website'
      url: site.link
  }


exports.doc = (head, req) ->
  ###
  This will render the content doc along with a list of its
  associated collections.
  ###
  # no need for double render on first hit
  return if req.client and req.initial_hit
  start code: 200, headers: {'Content-Type': 'text/html'}

  md = new Showdown.converter()
  theDoc = null
  collections = []
  author = null
  sponsor = null
  blocks = {}
  site = {}

  while row = getRow()
    doc = row.doc
    if doc
      theDoc ?= doc if doc.type in settings.app.content_types
      collections.push(doc) if doc.type is 'collection'
      sponsor ?= doc if doc.type is 'sponsor'
      author ?= doc if doc.type is 'author'
      blocks[doc.code] = doc if doc.type is 'block'
      site = doc if doc.type is 'site'

  # Let's just go back and use `doc` as the variable instead
  doc = theDoc

  transformDoc = (doc) ->
    if doc.intro?
      doc.intro_html = md.makeHtml(
        doc.intro.replace(/\{\{?baseURL\}?\}/g, dutils.getBaseURL(req))
      )
    doc.body_html = md.makeHtml(
      doc.body.replace(/\{\{?baseURL\}?\}/g, dutils.getBaseURL(req))
    )
    doc.published_at_html = utils.prettyDate(doc.published_at)
    doc.updated_at_html = utils.prettyDate(doc.updated_at)
    doc.fresh = utils.isItFresh(doc.published_at)
    doc.type_tc = utils.capitalize(doc.type)
    return doc

  doc = transformDoc(doc) if doc

  collections = _.map collections, (doc) ->
    if doc.intro?
      doc.intro_html = md.makeHtml(
        doc.intro.replace(/\{\{?baseURL\}?\}/g, dutils.getBaseURL(req))
      )
    doc.updated_at_html = utils.prettyDate(doc.updated_at)
    doc.fresh = utils.isItFresh(doc.updated_at)
    return doc

  if sponsor
    # Check for strat/end dates of sponsorship
    sponsor_start = moment.utc(doc.sponsor_start)
    sponsor_end = moment.utc(doc.sponsor_end)
    now = moment.utc()
    if sponsor_start.diff(now) <= 0 and sponsor_end.diff(now) >= 0
      # let's continue on
      sponsor.text_format = sponsor.format is 'text'
      sponsor.image_format = sponsor.format is 'image'
      sponsor.video_format = sponsor.format is 'video'
      sponsor.embed_format = sponsor.format is 'embed'
      sponsor.for_type = doc.type
      sponsor.for_type_tc = doc.type_tc
    else
      # let's remove the sponsor
      sponsor = null

  if doc
    return {
      on_dev: utils.isDev(req)
      site: site
      title: doc.title
      content: templates.render 'doc.html', req,
        doc: doc
        collections: collections
        collection: collections?[0] # primary one
        author: author
        sponsor: sponsor
        blocks: blocks
        nav: 'doc'
      og:
        site_name: site.name
        title: doc.title
        description: doc.intro
        type: 'article'
        image: "#{site.link}/file/#{doc._id}/#{doc.photo}" if doc.photo
        first_name: author?.name.split(' ')[0]
        last_name: author?.name.split(' ')[1]
        published: doc.published_at
    }
  else
    return {
      code: 404
      title: '404 Not Found'
      content: templates.render '404.html', req, { host: req.headers.Host }
      on_dev: utils.isDev(req)
    }


exports.rssfeed = (head, req) ->
  start code: 200, headers: {'Content-Type': 'application/xml'}
  # Output as plain text for troubleshooting
  # start code: 200, headers: {'Content-Type': 'text/plain'}

  md = new Showdown.converter()
  docs = []
  site = {}

  while row = getRow()
    doc = row.doc
    if doc
      docs.push(doc) if doc.type in settings.app.content_types
      site = doc if doc.type is 'site'

  docs = _.map docs, (doc) ->
    if doc.intro?
      doc.intro_html = md.makeHtml(
        doc.intro.replace(/\{\{?baseURL\}?\}/g, dutils.getBaseURL(req))
      )
    doc.body_html = md.makeHtml(
      doc.body.replace(/\{\{?baseURL\}?\}/g, dutils.getBaseURL(req))
    )
    doc.published_at = moment.utc(doc.published_at).toDate().toGMTString()
    doc.full_url = "#{site.link}/#{doc.type}/#{doc.slug}"
    doc.full_html = "#{doc.intro_html}<br><br>#{doc.body_html}"
    return doc

  return templates.render 'feed.xml', req,
    site: site
    docs: docs
    build_date: moment.utc().toDate().toGMTString()


exports.sitemap = (head, req) ->
  start code: 200, headers: {'Content-Type': 'application/xml'}

  docs = []
  siteLink = ''

  while row = getRow()
    key = row.key
    date = key[2]
    type = key[3]
    slug = key[4]
    if type is 'site'
      siteLink = slug if not siteLink
    else
      docs.push
        url: "#{siteLink}/#{type}/#{slug}"
        date: date

  return templates.render 'sitemap.html', req,
    docs: docs
