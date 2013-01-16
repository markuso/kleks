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

  # Search JSON endpoint
  {
    from: '/render/:site/json/search',
    to: '_search/site_docs'
  }

  # Essay content page
  {
    from: '/render/:site/essay/:slug',
    to: '_list/doc/docs_by_slug',
    query: {
      startkey: [':site', 'essay', ':slug'],
      endkey: [':site', 'essay', ':slug', {}],
      include_docs: 'true'
    }
  }

  # Scene content page
  {
    from: '/render/:site/scene/:slug',
    to: '_list/doc/docs_by_slug',
    query: {
      startkey: [':site', 'scene', ':slug'],
      endkey: [':site', 'scene', ':slug', {}],
      include_docs: 'true'
    }
  }

  # Video content page
  {
    from: '/render/:site/video/:slug',
    to: '_list/doc/docs_by_slug',
    query: {
      startkey: [':site', 'video', ':slug'],
      endkey: [':site', 'video', ':slug', {}],
      include_docs: 'true'
    }
  }

  # Profile content page
  {
    from: '/render/:site/profile/:slug',
    to: '_list/doc/docs_by_slug',
    query: {
      startkey: [':site', 'profile', ':slug'],
      endkey: [':site', 'profile', ':slug', {}],
      include_docs: 'true'
    }
  }

  # All docs list for site sorted by `updated_at`
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

  # `redirect` type - from a slug to a URL
  # doc id must be like `r/www.example.com/some-path`
  {
    from: '/render/:site/*',
    to: '_show/redirect/r/:site/*'
  }

  # 404 not found 
  { from: '/not-found', to: '_show/not_found' }

  # Catch all route
  { from: '*', to: '_show/not_found' }
]