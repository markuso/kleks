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
  site = null

  while row = getRow()
    doc = row.value
    collections.push(doc) if doc.type is 'collection'
    blocks[doc.code] = doc if doc.type is 'block'
    site ?= doc if doc.type is 'site'
  
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
    site: site
    title: "#{site.name}"
    content: templates.render "home.html", req,
      collections: collections
      blocks: blocks
      nav: 'home'
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
  site = null

  while row = getRow()
    doc = row.doc
    docs.push(doc) if doc.type in settings.app.content_types
    collection ?= doc if doc.type is 'collection'
    blocks[doc.code] = doc if doc.type is 'block'
    sponsor ?= doc if doc.type is 'sponsor'
    site ?= doc if doc.type is 'site'

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
      sponsor.for_type = collection.type
      sponsor.for_type_tc = collection.type_tc
    else
      # let's remove the sponsor
      sponsor = null

  if collection
    return {
      site: site
      title: collection.name
      content: templates.render 'collection.html', req,
        collection: collection
        docs: docs
        sponsor: sponsor
        blocks: blocks
        nav: 'collection'
    }
  else
    return {
      code: 404
      title: '404 Not Found'
      content: templates.render '404.html', req, { host: req.headers.Host }
    }


exports.docs = (head, req) ->
  # no need for double render on first hit
  return if req.client and req.initial_hit
  start code: 200, headers: {'Content-Type': 'text/html'}

  md = new Showdown.converter()
  docs = []
  site = null

  while row = getRow()
    doc = row.doc
    if doc.type in settings.app.content_types
      doc.collection_docs = []
      docs.push(doc)
    else if doc.type is 'collection'
      # Add the collection doc to the last doc pushed
      docs[docs.length-1].collection_docs.push(doc)
    site ?= doc if doc.type is 'site'

  docs = _.map docs, (doc) ->
    if doc.intro?
      doc.intro_html = md.makeHtml(
        doc.intro.replace(/\{\{?baseURL\}?\}/g, dutils.getBaseURL(req))
      )
    doc.published_at_html = utils.prettyDate(doc.published_at)
    doc.updated_at_html = utils.prettyDate(doc.updated_at)
    doc.fresh = utils.isItFresh(doc.published_at)
    doc.type_tc = utils.capitalize(doc.type)
    return doc

  return {
    site: site
    title: 'Docs List'
    content: templates.render 'docs.html', req,
      docs: docs
      nav: 'docs'
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
  site = null

  while row = getRow()
    doc = row.doc
    theDoc ?= doc if doc.type in settings.app.content_types
    collections.push(doc) if doc.type is 'collection'
    sponsor ?= doc if doc.type is 'sponsor'
    author ?= doc if doc.type is 'author'
    blocks[doc.code] = doc if doc.type is 'block'
    site ?= doc if doc.type is 'site'

  # Let's just go back and use `doc` as the variable instead
  doc = theDoc

  transformDoc = (doc) ->
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
      # let continue on
      sponsor.text_format = sponsor.format is 'text'
      sponsor.image_format = sponsor.format is 'image'
      sponsor.video_format = sponsor.format is 'video'
      sponsor.for_type = doc.type
      sponsor.for_type_tc = doc.type_tc
    else
      # let's remove the sponsor
      sponsor = null

  if doc
    return {
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
    }
  else
    return {
      code: 404
      title: '404 Not Found'
      content: templates.render '404.html', req, { host: req.headers.Host }
    }


exports.rssfeed = (head, req) ->
  # start code: 200, headers: {'Content-Type': 'application/rss+xml'}
  start code: 200, headers: {'Content-Type': 'text/plain'}

  md = new Showdown.converter()
  docs = []
  site = null

  while row = getRow()
    doc = row.doc
    docs.push(doc) if doc.type in settings.app.content_types
    site ?= doc if doc.type is 'site'

  docs = _.map docs, (doc) ->
    doc.intro_html = md.makeHtml(
      doc.intro.replace(/\{\{?baseURL\}?\}/g, dutils.getBaseURL(req))
    )
    doc.body_html = md.makeHtml(
      doc.body.replace(/\{\{?baseURL\}?\}/g, dutils.getBaseURL(req))
    )
    doc.published_at_html = utils.prettyDate(doc.published_at)
    doc.full_url = "#{site.link}/#{doc.type}/#{doc.slug}"
    doc.full_html = "#{doc.intro_html}<br>#{doc.body_html}"
    return doc

  return templates.render 'feed.xml', req,
    site: site
    docs: docs
    published_at: new Date(docs[0].published_at)
    build_date: new Date()
