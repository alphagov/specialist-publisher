(function(jQuery) {
  'use strict';

  var SpecialistDocument = {};

  SpecialistDocument.addPreviewFeature = function addPreviewFeature(args) {
    insertMarkup();
    addButtonPressListener();
    showMarkup();

    function insertMarkup(){
      $(args.insert_into).html(previewMarkup());
      $(args.insert_button).html(previewButton());
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
      $('.preview').show();
      $(window).trigger('displayPreviewDone');
    }

    function getPreview(){
      return $.ajax({
        url: args.url,
        context: document.body,
        data: args.data_target.apply(),
        type: 'post',
        dataType: 'json'
      });
    }

    function previewMarkup(){
      return '<div class="preview" style="display: none;">'
        + '  <div class="govspeak"></div>'
        + '</div>';
    }

    function previewButton(){
      return '<button name="preview" class="btn btn-primary">Preview</button>'
    }

    function buttonSelector(){
      return 'button[name="preview"]';
    }
  };

  window.SpecialistDocument = SpecialistDocument;
})($);
