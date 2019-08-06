/* jshint node: true */

module.exports = function(environment) {

  var ENV = {
    "modulePrefix": "client",
    "baseURL": "/",
    "locationType": "auto",
    "EmberENV": {
        "FEATURES": {
        }
    }
  }

  ENV.environment            = environment;
  ENV.EmberENV.PLATFORM_NAME = ENV.modulePrefix;

  ENV.APP = {
    "defaultLocale": "en",
    "customEvents": {
        "sortable_dragend": "sortable_dragend",
        "sortable_consume": "sortable_consume"
    }
  }

  ENV['simple-auth'] = {
    "authorizer": "authorizer:totem",
    "authenticationRoute": "/users/sign_in",
    "routeAfterAuthentication": "/spaces",
    "crossOriginWhitelist": [
        "http://localhost:3000",
        "http://ts.totem:3000"
    ],
    "store": "simple-auth-session-store:totem-cookie-store"
  }

  ENV.sassOptions = {
    "includePaths": [
        "node_modules/totem-assets/styles",
        "node_modules/thinkspace-assets/styles",
        "bower_components/foundation/scss",
        "bower_components/font-awesome/scss"
    ],
    "imagePath": "/assets/images"
  }

  ENV.totem = {
    "ajax_timeout": 25000,
    "locales": [
        "en"
    ],
    "simple_auth": {
        "sign_in_template": "thinkspace/common/users/sign_in",
        "validate_user_url": "api/thinkspace/common/users/validate",
        "sign_up_template": "thinkspace/common/users/sign_up",
        "switch_user_whitelist_regexps": [
            "\\/spaces\\/\\\\d+",
            "\\/casespace\\/cases\\/\\\\d+"
        ]
    },
    "messages": {
        "suppress_all": false,
        "loading_template": "totem_message_outlet/loading",
        "i18n_path_prefix": "casespace.api.success."
    },
    "session_timeout": {
        "time": 30,
        "warning_time": 2,
        "warning_decrement_by": 1,
        "warning_message": "Your session is about to timeout!"
    },
    "logger": {
        "log_level": "none",
        "log_trace": false
    },
    "pdfjs": {
        "worker_src": "/assets/pdfjs/pdf.worker.js"
    },
    "stylized_platform_name": "ThinkSpace",
    "grid": {
        "classes": {
            "columns": "ts-grid_columns",
            "sticky": "ts-grid_sticky"
        }
    },
    "pub_sub": {
        "namespace": "thinkspace"
    },
    "roles_map": {
        "read": "Student",
        "update": "Teaching Assistant",
        "owner": "Instructor"
    }
  }

  // Settings based on process.env
  ENV.totem.pusher_app_key              = process.env["APP_TOTEM_PUSHER_APP_KEY"]   || '';
  ENV.totem.api_host                    = process.env["APP_TOTEM_API_HOST"]         || 'http://localhost:3000';
  ENV.totem.asset_path                  = process.env["APP_TOTEM_ASSET_PATH"]       || 'http://localhost:4200/assets';
  ENV.totem.pub_sub.url                 = process.env["APP_TOTEM_PUB_SUB_URL"]      || 'http://localhost:4444';
  ENV.totem.pdfjs.worker_src            = process.env["APP_TOTEM_PDFJS_WORKER_SRC"] || '/assets/pdfjs/pdf.worker.js';
  ENV.totem.crisp_app_id                = process.env["APP_TOTEM_CRISP_APP_ID"]     || '';
  ENV.totem.pub_sub.socketio_client_cdn = process.env["APP_TOTEM_PUB_SUB_SOCKETIO_CLIENT_CDN"] || 'https://cdnjs.cloudflare.com/ajax/libs/socket.io/1.4.5/socket.io.min.js';
  ENV.totem.tos_link                    = process.env["APP_TOTEM_TOS_LINK"] || 'https://s3.amazonaws.com/thinkspace-prod/legal/terms.pdf';
  ENV.totem.pn_link                     = process.env["APP_TOTEM_PN_LINK"]  || 'https://s3.amazonaws.com/thinkspace-prod/legal/privacy-policy.pdf';

  if (environment === 'development') {
    // Ember configurations to support debugging.
    // ENV.APP.LOG_RESOLVER = true;
    // ENV.APP.LOG_ACTIVE_GENERATION = true;
    // ENV.APP.LOG_TRANSITIONS = true;
    // ENV.APP.LOG_TRANSITIONS_INTERNAL = true;
    // ENV.APP.LOG_VIEW_LOOKUPS = true;

    ENV.contentSecurityPolicy = {
      "default-src": "* localhost:* 0.0.0.0:* 'unsafe-eval' 'unsafe-inline' data:",
      "script-src":  "* localhost:* 0.0.0.0:* 'unsafe-eval' 'unsafe-inline' data:",
      "font-src":    "* localhost:* 0.0.0.0:* 'unsafe-eval' 'unsafe-inline' data:",
      "connect-src": "* localhost:* 0.0.0.0:* 'unsafe-eval' 'unsafe-inline' data:",
      "img-src":     "* localhost:* 0.0.0.0:* 'unsafe-eval' 'unsafe-inline' data: blob:",
      "style-src":   "* localhost:* 0.0.0.0:* 'unsafe-eval' 'unsafe-inline' data:",
      "media-src":   "* localhost:* 0.0.0.0:* 'unsafe-eval' 'unsafe-inline' data:"
    }

  }

  if (environment === 'test') {
    // Testem prefers this...
    ENV.baseURL = '/';
    ENV.locationType = 'none';

    // keep test console output quieter
    ENV.APP.LOG_ACTIVE_GENERATION = false;
    ENV.APP.LOG_VIEW_LOOKUPS = false;
    ENV.APP.rootElement = '#ember-testing';
  }

  return ENV;
};
