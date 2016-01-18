//= require jquery
//= require select2

jQuery(function($) {
  $(".select2").select2({
    placeholder: $(this).data('placeholder')
  });

  $('.js-hidden').hide();

  $('.js-update-type-major').click(function() {
    $('.js-change-note').show();
  });

  $('.js-update-type-minor').click(function() {
    $('.js-change-note').hide();
  });
});
