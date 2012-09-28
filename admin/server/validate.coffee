utils = require('lib/utils')

exports.validate_doc_update = (newDoc, oldDoc, userCtx) ->

  is_admin = if '_admin' in userCtx.roles then true else false

  if not is_admin
    throw unauthorized: 'You are not a database admin'

  if newDoc.type is 'essay'
    if not newDoc.site
      throw forbidden: 'site is a required field'

    if not utils.cleanSlug newDoc.slug
      throw forbidden: 'slug is a required field'
    
    if not newDoc.title
      throw forbidden: 'title is a required field'
    
    if newDoc.published
      if not newDoc.published_at
        throw forbidden: 'Published essay must have a publish date'
