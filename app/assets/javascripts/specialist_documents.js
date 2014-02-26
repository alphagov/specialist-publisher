(function(jQuery) {
  'use strict';

  var SpecialistDocument = {};

  SpecialistDocument.enhancePreview = function enhancePreview(args) {
    $(args.button_selector).click(function(e) {
      e.preventDefault();

      getPreview().done(function(response) {
        displayPreview(response.preview_html);
      });
    });

    function displayPreview(previewHtml) {
      $(args.render_to).html(previewHtml);
    }

    function getPreview(){
      return $.ajax({
        url: '/specialist-documents/preview',
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
  };

  window.SpecialistDocument = SpecialistDocument;
})($);
