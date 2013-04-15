Setup & Deployment
------------------

For new setup, begin with installing dependencies as follows:

    $ cd ~/CouchApps/kleks/admin
    $ kanso install
    $ cd ~/CouchApps/kleks/site
    $ kanso install

Push the current app (site or admin) to development CouchDB

    $ kanso push

Once a `.kansorc` file is created with a production config setting named `live` then we can deploy to prodcution using:

    $ kanso push live
