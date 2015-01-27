//= require vendor/jquery-1.11.0.min
//= require vendor/jquery-ui.min.js

//= require govuk_toolkit
//= require ajax_setup
//= require length_counter
//= require specialist_documents
//= require toggle_hide_with_check_box
//= require select2

function initPrimaryLinks(){
  GOVUK.primaryLinks.init('.primary-item');
}
$(initPrimaryLinks);
$(window).on('displayPreviewDone', initPrimaryLinks);

jQuery(function($) {
  $(".select2").select2({
    placeholder: $(this).data('placeholder')
  });

  $(".js-length-counter").each(function(){
    new GOVUK.LengthCounter({$el:$(this)});
  })

  $(".reorderable-document-list").sortable();
});
