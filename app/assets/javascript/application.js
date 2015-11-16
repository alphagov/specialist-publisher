//= require jquery
//= require select2

jQuery(function($) {
  $(".select2").select2({
    placeholder: $(this).data('placeholder')
  });
});
