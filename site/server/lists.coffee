templates = require('duality/templates')
dutils    = require('duality/utils')
Showdown  = require('showdown')
_         = require('underscore')._


exports.home = (head, req) ->
  # no need for double render on first hit
  return if req.client and req.initial_hit
  start code: 200, headers: {'Content-Type': 'text/html'}

  converter = new Showdown.converter()
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
      doc.intro_html = converter.makeHtml(
        doc.intro.replace(/\{\{?baseURL\}?\}/g, dutils.getBaseURL(req))
      )
    doc.updated_at_html = new Date(doc.updated_at).toDateString()
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

  converter = new Showdown.converter()
  essays = []
  collection = null
  sponsor = null
  site = null

  while row = getRow()
    doc = row.doc
    essays.push(doc) if doc.type is 'essay'
    collection ?= doc if doc.type is 'collection'
    sponsor ?= doc if doc.type is 'sponsor'
    site ?= doc if doc.type is 'site'

  essays = _.map essays, (doc) ->
    if doc.intro?
      doc.intro_html = converter.makeHtml(
        doc.intro.replace(/\{\{?baseURL\}?\}/g, dutils.getBaseURL(req))
      )
    doc.published_at_html = new Date(doc.published_at).toDateString()
    return doc

  if sponsor
    sponsor.text_format = sponsor.format is 'text'
    sponsor.image_format = sponsor.format is 'image'
    sponsor.video_format = sponsor.format is 'video'

  return {
    site: site
    title: collection.name
    content: templates.render 'collection.html', req,
      collection: collection
      essays: essays
      sponsor: sponsor
      nav: 'collection'
  }


exports.essays = (head, req) ->
  # no need for double render on first hit
  return if req.client and req.initial_hit
  start code: 200, headers: {'Content-Type': 'text/html'}

  converter = new Showdown.converter()
  essays = []
  site = null

  while row = getRow()
    doc = row.doc
    if doc.type is 'essay'
      doc.collection_docs = []
      essays.push(doc)
    else if doc.type is 'collection'
      # Add the collection doc to the last essay doc pushed
      essays[essays.length-1].collection_docs.push(doc)
    site ?= doc if doc.type is 'site'

  essays = _.map essays, (doc) ->
    if doc.intro?
      doc.intro_html = converter.makeHtml(
        doc.intro.replace(/\{\{?baseURL\}?\}/g, dutils.getBaseURL(req))
      )
    doc.published_at_html = new Date(doc.published_at).toDateString()
    doc.updated_at_html = new Date(doc.updated_at).toDateString()
    return doc

  return {
    site: site
    title: 'Essays List'
    content: templates.render 'essays.html', req,
      essays: essays
      nav: 'essays'
  }


exports.essay = (head, req) ->
  ###
  This will render the Essay content along with a list of its
  associated collections.
  ###
  # no need for double render on first hit
  return if req.client and req.initial_hit
  start code: 200, headers: {'Content-Type': 'text/html'}

  converter = new Showdown.converter()
  essay = null
  collections = []
  author = null
  sponsor = null
  site = null

  while row = getRow()
    doc = row.doc
    essay ?= doc if doc.type is 'essay'
    collections.push(doc) if doc.type is 'collection'
    sponsor ?= doc if doc.type is 'sponsor'
    author ?= doc if doc.type is 'author'
    site ?= doc if doc.type is 'site'

  transformEssay = (doc) ->
    doc.intro_html = converter.makeHtml(
      doc.intro.replace(/\{\{?baseURL\}?\}/g, dutils.getBaseURL(req))
    )
    doc.body_html = converter.makeHtml(
      doc.body.replace(/\{\{?baseURL\}?\}/g, dutils.getBaseURL(req))
    )
    doc.published_at_html = new Date(doc.published_at).toDateString()
    doc.updated_at_html = new Date(doc.updated_at).toDateString()
    return doc

  essay = transformEssay(essay)

  collections = _.map collections, (doc) ->
    if doc.intro?
      doc.intro_html = converter.makeHtml(
        doc.intro.replace(/\{\{?baseURL\}?\}/g, dutils.getBaseURL(req))
      )
    doc.updated_at_html = new Date(doc.updated_at).toDateString()
    return doc

  if sponsor
    sponsor.text_format = sponsor.format is 'text'
    sponsor.image_format = sponsor.format is 'image'
    sponsor.video_format = sponsor.format is 'video'

  return {
    site: site
    title: essay.title
    content: templates.render 'essay.html', req,
      essay: essay
      collections: collections
      author: author
      sponsor: sponsor
      nav: 'essay'
  }


###
exports.rssfeed = function (head, req) {
    start({code: 200, headers: {'Content-Type': 'application/rss+xml'}});

    var converter = new Showdown.converter();

    var rows = getRows(function (row) {
        var doc = row.doc;
        doc.markdown_html = converter.makeHtml(
            doc.markdown.replace(/\{\{?baseURL\}?\}/g, dutils.getBaseURL(req))
        );
        doc.guid = 'http://caolanmcmahon.com' + (
            doc.oldurl || '/posts/' + doc.slug
        );
        return row;
    });

    return templates.render('feed.xml', req, {
        rows: rows,
        published_at: rows[0].doc.published_at,
        builddate: new Date()
    });
};

###