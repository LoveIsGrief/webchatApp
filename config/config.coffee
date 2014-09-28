path     = require 'path'
rootPath = path.normalize __dirname + '/..'
env      = process.env.NODE_ENV || 'development'

config =
  development:
    root: rootPath
    app:
      name: 'webchat'
    port: 3000
    db: "#{rootPath}/dbs/development.json"

  test:
    root: rootPath
    app:
      name: 'webchat'
    port: 3000
    db: "#{rootPath}/dbs/test.json"


  production:
    root: rootPath
    app:
      name: 'webchat'
    port: 3000
    db: "#{rootPath}/dbs/production.json"


module.exports = config[env]
