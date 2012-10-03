exports.docs_for_home =
  map: (doc) ->
    # List of collections sorted by `pinned` then `updated_at`,
    # plus a few blocks that are needed on home page,
    # and the site configuration doc.
    if doc.site and doc.type is 'collection' and doc.updated_at
      pinned = if doc.pinned then 1 else 0
      timestamp = new Date(doc.updated_at).getTime()
      emit [doc.site, 'collection', pinned, timestamp], doc
    else if doc.type is 'block' and doc.code in ['site_intro','site_promo']
      emit [doc.site, 'block'], doc
    else if doc.type is 'site'
      # Also add the site doc
      emit [doc._id, 'site'], doc


exports.essays_by_collection =
  map: (doc) ->
    if doc.site and doc.type is 'essay' and doc.collections and doc.published_at and doc.published
      timestamp = new Date(doc.published_at).getTime()
      for c, i in doc.collections
        emit [doc.site, c.slug, 'essay', timestamp], null
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


exports.essays_by_date =
  map: (doc) ->
    # List of essays sorted by `published_at` along with their collection references
    if doc.site and doc.type is 'essay' and doc.published_at and doc.published
      timestamp = new Date(doc.published_at).getTime()
      emit [doc.site, timestamp, doc._id, {}], null
      for c, i in doc.collections
        # To get each collection's doc
        emit [doc.site, timestamp, doc._id, i+1], {_id: c.id}
    else if doc.type is 'site'
      # Also add the site doc
      emit [doc._id], null


exports.essays_by_slug =
  map: (doc) ->
    # Essay key by slug followed with it's collection references
    if doc.site and doc.type is 'essay' and doc.slug
      emit [doc.site, doc.slug, 'essay', 0], null
      for c, i in doc.collections
        # To get each collection's doc
        emit [doc.site, doc.slug, 'collection', i+1], {_id: c.id}
      # Also add the essay's author doc
      emit [doc.site, doc.slug, 'author', {}], { _id: doc.author_id } if doc.author_id
      # Also add the essay's sponsor doc
      emit [doc.site, doc.slug, 'sponsor', {}], { _id: doc.sponsor_id } if doc.sponsor_id
      # Also add the essay's associated blocks
      if doc.blocks
        for block_id, i in doc.blocks
          emit [doc.site, doc.slug, 'block', {}], { _id: block_id }
      # Also add the site doc
      emit [doc.site, doc.slug, 'site', {}], { _id: doc.site }
