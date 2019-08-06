/**
 * @license Copyright (c) 2003-2015, CKSource - Frederico Knabben. All rights reserved.
 * For licensing, see LICENSE.md or http://ckeditor.com/license
 */
CKEDITOR.on(
   'instanceReady',
   function(ev) {
      var $script = document.createElement('script'),
         $editor_instance = CKEDITOR.instances[ev.editor.name];

      $script.src = '//use.typekit.net/wtx3nyl.js';
      $script.onload = function() {
         try{$editor_instance.window.$.Typekit.load({protocol: 'https:'});}catch(e){}
      };

      $editor_instance.document.getHead().$.appendChild($script);
   }
);

CKEDITOR.editorConfig = function( config ) {
  var $links;
  var contents_css;
  $links = $(document).find('link');
  $.each($links, (function(_this) {
    return function(index, link) {
      var $link, href, is_css;
      $link  = $(link);
      href   = $link.prop('href');
      is_css = href.indexOf('thinkspace') !== -1 && href.indexOf('css') !== -1;
      if (is_css) {
        contents_css = href;
      }
    };
  })(this));

  
  config.skin           = 'moono';
  config.customConfig   = '';
  config.contentsCss    = contents_css;
  config.allowedContent = true;
  config.autoParagraph  = false;
  config.extraPlugins   = ['forms', 'colorbutton', 'panelbutton', 'justify', 'pastefromword', 'iframe'];
  config.removePlugins  = ['magicline'];

  config.toolbar = [
    {name: 'document',    items: ['Source', '-', 'Print']},
    {name: 'forms',       items: ['Checkbox', 'TextField', 'Textarea', 'Radio']},
    {name: 'paragraph',   items: ['NumberedList', 'BulletedList', '-', 'Outdent', 'Indent', '-', 'JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock']},
    {name: 'basicstyles', items: ['Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript', '-', 'RemoveFormat']},
    {name: 'insert',      items: ['Image', 'Table', 'HorizontalRule', 'SpecialChar']},
    {name: 'links',       items: ['Link', 'Unlink']},
    {name: 'styles',      items: ['Format']},
    {name: 'colors',      items: ['TextColor', 'BGColor']},
    {name: 'clipboard',   items: ['PasteFromWord']},
    {name: 'plugins',     items: ['Iframe']}
  ];

};
