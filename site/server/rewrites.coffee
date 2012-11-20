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
    to: '_list/rssfeed/docs_for_feeds',
    query: {
      startkey: [':site', 'content', {}, {}],
      endkey: [':site', 'content', null],
      descending: 'true',
      include_docs: 'true',
      limit: '11'
    }
  }

  # Sitemap.xml file of all docs sorted by `updated_at`
  {
    from: '/render/:site/sitemap.xml',
    to: '_list/sitemap/docs_for_feeds',
    query: {
      startkey: [':site'],
      endkey: [':site', {}]
    }
  }

  # File attachments paths
  { from: '/file/:id/:filename', to: '../../:id/:filename' }
  { from: '/render/:site/file/:id/:filename', to: '../../:id/:filename' }
  
  # Redirected old URLs using a pattern
  movedPattern '/render/:site/posts/:id/:slug', '/:type/:slug'

  # Redirect some direct paths
  # moved '/render/:site/some-old-path', '/some-new-path'

  # For science.evolvingteachers.com old urls
  moved '/render/:site/snc4m1-curriculum-course-material/', '/essay/snc4m1-curriculum-course-material'
  moved '/render/:site/snc3m1-svn3m1-curriculum-course-material/', '/collection/grade-11-science'
  moved '/render/:site/snc2d1-snc2p1-curriculum-course-material/', '/collection/grade-10-science'
  moved '/render/:site/snc1d1-snc1p1-curriculum-course-material/', '/collection/grade-9-science'

  # 404 not found 
  { from: '/not-found', to: '_show/not_found' }

  # Catch all route
  { from: '*', to: '_show/not_found' }
]