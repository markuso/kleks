moved = (from, to) ->
  { from: from, to: '_show/moved', query: {loc: to} }

movedPattern = (from, to) ->
  { from: from, to: '_show/moved_pattern', query: {loc: to} }


module.exports = [
  # Static files from the root
  { from: '/static/*', to: 'static/*' }

  # Dynamic site rendering used with a virtual host like:
  # www.evitaochel.com = /kleks/_design/site/_rewrite/render/evitaochel
  {
    from: '/render/:site',
    to: '_list/home/docs_for_home',
    query: {
      startkey: [':site', {}],
      endkey: [':site'],
      descending: 'true'
    }
  }

  # Some routes to static files needed under the dynamic site path
  { from: '/render/:site/static/*',    to: 'static/*' }
  { from: '/render/:site/modules.js',  to: 'modules.js' }
  { from: '/render/:site/duality.js',  to: 'duality.js' }

  # Collection page - list of docs
  {
    from: '/render/:site/collection/:slug',
    to: '_list/collection/docs_by_collection',
    query: {
      startkey: [':site', ':slug', {}],
      endkey: [':site', ':slug'],
      descending: 'true',
      include_docs: 'true'
    }
  }

  # Collection JSON view - list of docs ONLY
  {
    from: '/render/:site/json/collection/:slug',
    to: '_view/docs_by_collection',
    query: {
      startkey: [':site', ':slug', 'doc', {}],
      endkey: [':site', ':slug', 'doc'],
      descending: 'true',
      include_docs: 'true'
    }
  }

  # Doc content page
  {
    from: '/render/:site/:type/:slug',
    to: '_list/doc/docs_by_slug',
    query: {
      startkey: [':site', ':type', ':slug'],
      endkey: [':site', ':type', ':slug', {}],
      include_docs: 'true'
    }
  }

  # Docs list for site sorted by `updated_at`
  {
    from: '/render/:site/docs',
    to: '_list/docs/docs_by_date',
    query: {
      startkey: [':site', {}],
      endkey: [':site'],
      descending: 'true',
      include_docs: 'true'
    }
  }

  # RSS Feed of all docs sorted by `updated_at`
  {
    from: '/render/:site/feed',
    to: '_list/rssfeed/docs_by_date',
    query: {
      startkey: [':site', {}],
      endkey: [':site'],
      descending: 'true',
      include_docs: 'true'
    }
  }

  # File attachments paths
  { from: '/file/:id/:filename', to: '../../:id/:filename' }
  { from: '/render/:site/file/:id/:filename', to: '../../:id/:filename' }

  # Redirect some direct paths
  # moved '/posts/some-old-path', '/some-new-path'
  
  # Redirected old URLs using a pattern
  movedPattern '/render/:site/posts/:id/:slug', '/:type/:slug'

  # 404 not found 
  { from: '/not-found', to: '_show/not_found' }

  # Catch all route
  { from: '*', to: '_show/not_found' }
]