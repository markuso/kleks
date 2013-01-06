
exports.docs_for_home =
  map: (doc) ->
    # List of collections sorted by `pinned` then `updated_at`,
    # plus a few blocks that are needed on home page,
    # and the site configuration doc.
    blocks = ['site_intro','site_promo','site_home']
    if doc.site and doc.type is 'collection' and doc.updated_at
      pinned = if doc.pinned then 1 else 0
      timestamp = new Date(doc.updated_at).getTime()
      emit [doc.site, 'collection', pinned, timestamp], doc
    else if doc.type is 'block' and doc.code and blocks.indexOf(doc.code) >= 0
      emit [doc.site, 'block'], doc
    else if doc.type is 'site'
      # Also add the site doc
      emit [doc._id, 'site'], doc


exports.docs_by_collection =
  map: (doc) ->
    types = ['essay','scene','video','profile']
    if doc.site and doc.type and types.indexOf(doc.type) >= 0 and doc.collections and doc.published_at and doc.published
      timestamp = new Date(doc.published_at).getTime()
      if doc.collections
        for c, i in doc.collections
          emit [doc.site, c.slug, 'doc', timestamp], null
    else if doc.site and doc.type is 'collection'
      emit [doc.site, doc.slug, 'collection', {}], null
      # Also add the collection's sponsor doc
      emit [doc.site, doc.slug, 'sponsor', {}], { _id: doc.sponsor_id } if doc.sponsor_id
      # Also add the collection's associated blocks
      if doc.blocks
        for block_id, i in doc.blocks
          emit [doc.site, doc.slug, 'block', {}], { _id: block_id }
      # Also add the site doc
      emit [doc.site, doc.slug, 'site', {}], { _id: doc.site }


exports.docs_by_date =
  map: (doc) ->
    # List of content docs sorted by `published_at` along with their collection references
    types = ['essay','scene','video','profile']
    if doc.site and doc.type and types.indexOf(doc.type) >= 0 and doc.published_at and doc.published
      timestamp = new Date(doc.published_at).getTime()
      emit [doc.site, timestamp, doc._id, {}], null
      if doc.collections
        for c, i in doc.collections
          # To get each collection's doc
          emit [doc.site, timestamp, doc._id, i+1], {_id: c.id}
    else if doc.type is 'site'
      # Also add the site doc
      emit [doc._id, null], null


exports.docs_by_slug =
  map: (doc) ->
    # Content doc key by slug followed with it's collection references
    types = ['essay','scene','video','profile']
    if doc.site and doc.type and types.indexOf(doc.type) >= 0 and doc.slug
      emit [doc.site, doc.type, doc.slug, 'doc', 0], null
      if doc.collections
        for c, i in doc.collections
          # To get each collection's doc
          emit [doc.site, doc.type, doc.slug, 'collection', i+1], {_id: c.id}
      # Also add the doc's author doc
      emit [doc.site, doc.type, doc.slug, 'author', {}], { _id: doc.author_id } if doc.author_id
      # Also add the doc's sponsor doc
      emit [doc.site, doc.type, doc.slug, 'sponsor', {}], { _id: doc.sponsor_id } if doc.sponsor_id
      # Also add the doc's associated blocks
      if doc.blocks
        for block_id, i in doc.blocks
          emit [doc.site, doc.type, doc.slug, 'block', {}], { _id: block_id }
      # Also add the site doc
      emit [doc.site, doc.type, doc.slug, 'site', {}], { _id: doc.site }


exports.docs_for_feeds =
  map: (doc) ->
    types = ['essay','scene','video','profile']
    if doc.type is 'site'
      # Make first and last rows as the same site doc
      emit [doc._id, 'content', null, doc.type, doc.link], null
      emit [doc._id, 'content', {}, doc.type, doc.link], null
    else if doc.slug and doc.type
      date = doc.updated_at
      date = doc.published_at unless date
      date = new Date().toISOString() unless date
      if doc.type and types.indexOf(doc.type) >= 0
        emit [doc.site, 'content', date, doc.type, doc.slug], null
      else
        emit [doc.site, 'x-other', date, doc.type, doc.slug], null


exports.redirects_by_slug =
  map: (doc) ->
    if doc.site and doc.type and doc.type is 'redirect' and doc.slug and doc.location
      emit [doc.site, doc.slug], doc.location
    