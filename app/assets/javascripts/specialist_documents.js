(function(jQuery) {
  'use strict';

  var SpecialistDocument = {};

  SpecialistDocument.addPreviewFeature = function addPreviewFeature(args) {
    insertMarkup();
    addButtonPressListener();
    showMarkup();

    function insertMarkup(){
      $(args.insert_into).html(previewMarkup());
    }

    function addButtonPressListener(){
      $(buttonSelector()).click(function(e) {
        e.preventDefault();

        getPreview().done(function(response) {
          displayPreview(response.preview_html);
        });
      });
    }

    function showMarkup(){
      $(args.insert_into).show();
    }

    function displayPreview(previewHtml) {
      $(args.render_to).html(previewHtml);
      $(window).trigger('displayPreviewDone');
    }

    function getPreview(){
      return $.ajax({
        url: args.url,
        context: document.body,
        data: {
          'specialist_document' : {
            'body' : $('#specialist_document_body').val()
          }
        },
        type: 'post',
        dataType: 'json'
      });
    }

    function previewMarkup(){
      return '<button name="preview">Preview</button>'
        + '<div class="preview">'
        + '  <div class="govspeak"></div>'
        + '</div>';
    }

    function buttonSelector(){
      return 'button[name="preview"]';
    }
  };

  window.SpecialistDocument = SpecialistDocument;
})($);
