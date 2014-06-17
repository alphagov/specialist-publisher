//= require vendor/jquery-1.11.0.min
//= require vendor/bootstrap
//= require govuk_toolkit
//= require ajax_setup
//= require length_counter
//= require specialist_documents
//= require toggle_hide_with_check_box

function initPrimaryLinks(){
  GOVUK.primaryLinks.init('.primary-item');
}
$(initPrimaryLinks);
$(window).on('displayPreviewDone', initPrimaryLinks);

jQuery(function($) {
  $(".js-length-counter").each(function(){
    new GOVUK.LengthCounter({$el:$(this)});
  })
});
