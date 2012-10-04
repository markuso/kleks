utils    = require('lib/utils')
settings = require('settings/root')

exports.validate_doc_update = (newDoc, oldDoc, userCtx) ->

  access = if '_admin' in userCtx.roles or 'admin' in userCtx.roles or 'manager' in userCtx.roles then true else false

  if not access
    throw unauthorized: 'You must have the role admin or manager to make changes'

  if newDoc.type in settings.app.content_types
    throw forbidden: 'site is a required field' unless newDoc.site
    throw forbidden: 'title is a required field' unless newDoc.title

    newDoc.slug = utils.cleanSlug newDoc.slug
    throw forbidden: 'slug is a required field' unless newDoc.slug
    
    if newDoc.published
      throw forbidden: 'Published essay must have a publish date' unless newDoc.published_at
