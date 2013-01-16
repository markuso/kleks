
exports.site_docs =
  index: (doc) ->
    blocks = ['site_intro','site_home']
    types = ['essay','scene','video','profile']
    
    if doc.site and doc.type and types.indexOf(doc.type) >= 0 and doc.published is true
      content = doc.title + ' ' + doc.intro + ' ' + doc.body
      
      published = parseInt(doc.published_at.replace(/-/g,'').split('T')[0]) or 0
      updated = parseInt(doc.updated_at.replace(/-/g,'').split('T')[0]) or 0
    
      index 'default', content
      index 'site', doc.site
      index 'type', doc.type, {'store': 'yes'}
      index 'slug', doc.slug, {'store': 'yes'}
      index 'title', doc.title, {'store': 'yes'}
      index 'published', published, {'store': 'yes'}
      index 'updated', updated, {'store': 'yes'}

    else if doc.site and doc.type is 'collection'
      content = doc.name + ' ' + doc.intro
      index 'default', content
      index 'site', doc.site
      index 'type', doc.type, {'store': 'yes'}
      index 'slug', doc.slug, {'store': 'yes'}
      index 'title', doc.name, {'store': 'yes'}

    else if doc.type is 'block' and doc.code and blocks.indexOf(doc.code) >= 0 and doc.enabled is true
      index 'default', doc.content
      index 'site', doc.site
      index 'type', doc.type, {'store': 'yes'}
