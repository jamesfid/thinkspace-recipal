/* jshint node: true */
'use strict';

module.exports = {
  name: 'thinkspace-assets',
  contentFor: function(type, config, content) {
    if (type === 'head') {
      var add = [];
      
      add.push('<script type="text/javascript" src="//use.typekit.net/wtx3nyl.js"></script>');
      add.push('<script type="text/javascript">try{Typekit.load();}catch(e){}</script>');
      if (config.environment === 'production') {
        add.push('<link rel="icon" href="https://s3.amazonaws.com/thinkspace-prod/assets/images/favicon.ico">');
        add.push('<script src="//js.pusher.com/3.0/pusher.min.js"></script>');
      }
      return add.join('\n');
    }
  }
};
