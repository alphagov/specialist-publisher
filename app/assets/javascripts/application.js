//= require vendor/jquery-1.11.0.min
//= require vendor/bootstrap
//= require govuk_toolkit
//= require ajax_setup
//= require specialist_documents

function initPrimaryLinks(){
  GOVUK.primaryLinks.init('.primary-item');
}
$(initPrimaryLinks);
$(window).on('displayPreviewDone', initPrimaryLinks);
