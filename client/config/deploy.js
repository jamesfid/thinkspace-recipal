// Must have an entry for every environment we wish to use, even thought it causes repetition.
// See http://ember-cli-deploy.com/docs/v0.4.x/configuration/
module.exports = {

    development: {
      buildEnv: 'development',
      store: {
        type:     process.env['APP_DEPLOY_STORE_TYPE'],
        host:     process.env['APP_DEPLOY_STORE_HOST'],
        port:     process.env['APP_DEPLOY_STORE_PORT'],
        password: process.env['APP_DEPLOY_STORE_PASSWORD']
      },
      assets: {
        type:            's3', 
        gzip:            false,
        gzipExtensions:  ['js', 'css', 'svg'], 
        accessKeyId:     process.env['APP_DEPLOY_ASSETS_ACCESS_KEY_ID'],
        secretAccessKey: process.env['APP_DEPLOY_ASSETS_SECRET_ACCESS_KEY'],
        bucket:          process.env['APP_DEPLOY_ASSETS_BUCKET']
      }
    },
  
    staging: {
      buildEnv: 'staging',
      store: {
        type:     process.env['APP_DEPLOY_STORE_TYPE'],
        host:     process.env['APP_DEPLOY_STORE_HOST'],
        port:     process.env['APP_DEPLOY_STORE_PORT'],
        password: process.env['APP_DEPLOY_STORE_PASSWORD']
      },
      assets: {
        accessKeyId:     process.env['APP_DEPLOY_ASSETS_ACCESS_KEY_ID'],
        secretAccessKey: process.env['APP_DEPLOY_ASSETS_SECRET_ACCESS_KEY'],
        bucket:          process.env['APP_DEPLOY_ASSETS_BUCKET']
      }
    },
  
     production: {
      buildEnv: 'production',
      store: {
        type:     process.env['APP_DEPLOY_STORE_TYPE'],
        host:     process.env['APP_DEPLOY_STORE_HOST'],
        port:     process.env['APP_DEPLOY_STORE_PORT'],
        password: process.env['APP_DEPLOY_STORE_PASSWORD']
      },
      assets: {
        accessKeyId:     process.env['APP_DEPLOY_ASSETS_ACCESS_KEY_ID'],
        secretAccessKey: process.env['APP_DEPLOY_ASSETS_SECRET_ACCESS_KEY'],
        bucket:          process.env['APP_DEPLOY_ASSETS_BUCKET']
      }
    }

  };
  