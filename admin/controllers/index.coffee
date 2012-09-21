Spine       = require('spine/core')
templates   = require('duality/templates')
session     = require('session')

# Sites       = require('controllers/sites')
# Authors     = require('controllers/authors')
# Collections = require('controllers/collections')
# Essays      = require('controllers/essays')
# Blocks      = require('controllers/blocks')
# Sponsors    = require('controllers/sponsors')
# Contacts    = require('controllers/contacts')

Site        = require('models/site')
Author      = require('models/author')
Collection  = require('models/collection')
Essay       = require('models/essay')
Block       = require('models/block')
Sponsor     = require('models/sponsor')
Contact     = require('models/contact')


class App extends Spine.Controller
  
  constructor: ->
    super
    @checkSession()

  checkSession: ->
    session.info (err, info) =>
      if '_admin' in info.userCtx.roles
        @render()
      else
        username = 'admin'
        pass = 'couchaxs'
        session.login username, pass, (err, resp) =>
          if err
            alert "Error logging in as #{username}: #{err}"
          else
            if '_admin' in resp.roles
              @render()
            else
              alert "User #{username} does not have permission"

  render: ->
    site = new Sites
    Site.fetch()
    Author.fetch()
    Collection.fetch()
    Essay.fetch()
    Block.fetch()
    Sponsor.fetch()
    Contact.fetch()

    @context =
      sites: Site.all()
      authors: Author.all()
      collections: Collection.all()
      essays: Essay.all()
      blocks: Block.all()
      sponsors: Sponsor.all()
      contacts: Contact.all()

    @el.html templates.render('home.html', {}, @context)


module.exports = App
    