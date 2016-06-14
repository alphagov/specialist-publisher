//= require jquery
//= require select2
//= require length_counter

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

  $(".js-length-counter").each(function(){
    new GOVUK.LengthCounter({$el:$(this)});
  });

  $("#preview-button").click(function(){
      $('.preview_container').removeClass('hide');
      var bodyText = $('.body-text').val();
      $.post(
          "/preview",
          { bodyText: bodyText
          },
          function(data) {
              $('.govspeak').html(data['renderedGovspeak']);
          }
      );
      return false;
  });
});
