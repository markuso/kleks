moved = (from, to) ->
  { from: from, to: '_show/moved', query: {loc: to} }

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

  # List of all Essays sorted by `updated_at`
  {
    from: '/render/:site/essays',
    to: '_list/essays/essays_by_date',
    query: {
      startkey: [':site', {}],
      endkey: [':site'],
      descending: 'true',
      include_docs: 'true'
    }
  }

  # Collection's page - list of essays
  # `:cid` is the collection's _id
  {
    from: '/render/:site/collection/:cid',
    to: '_list/collection/essays_by_collection',
    query: {
      startkey: [':site', ':cid', {}],
      endkey: [':site', ':cid'],
      descending: 'true',
      include_docs: 'true'
    }
  }

  # Essay's content page
  # `:slug` is the essay's slug
  {
    from: '/render/:site/essay/:slug',
    to: '_list/essay/essays_by_slug',
    query: {
      startkey: [':site', ':slug'],
      endkey: [':site', ':slug', {}],
      include_docs: 'true'
    }
  }

  # Redirected old URLs
  # moved '/posts/some-old-path', '/some-new-path'

  # 404 not found 
  { from: '/not-found', to: '_show/not_found' }

  # Catch all route
  { from: '*', to: '_show/not_found' }
]