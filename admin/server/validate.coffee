utils    = require('lib/utils')

exports.validate_doc_update = (newDoc, oldDoc, userCtx) ->
  types = ['essay','scene','video','profile']

  access = if '_admin' in userCtx.roles or '_creator' in userCtx.roles or 'admin' in userCtx.roles or 'manager' in userCtx.roles then true else false

  if not access
    throw unauthorized: 'You must have the role admin or manager to make changes'

  if newDoc.type in types
    throw forbidden: 'site is a required field' unless newDoc.site
    throw forbidden: 'title is a required field' unless newDoc.title

    newDoc.slug = utils.cleanSlug newDoc.slug
    throw forbidden: 'slug is a required field' unless newDoc.slug
    
    if newDoc.published
      throw forbidden: 'Published doc must have a publish date' unless newDoc.published_at
