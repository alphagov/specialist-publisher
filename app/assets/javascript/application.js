//= require jquery
//= require select2
//= require length_counter

jQuery(function($) {
  $(".select2").select2({
    placeholder: $(this).data('placeholder')
  });

  ////
  // Make a select2 that will create new values on return as you type them
  (function () {
    var element = $(".free-form-list");
    if (element.length === 0) return;

    var value = element.val();
    var tags = (value === "") ? [] : value.split("::");

    element.select2({
      tags: tags,
      separator: "::"
    }).on("change", function (event) {
      var added = event.added;

      if (typeof added !== "undefined" && tags.indexOf(added.text) === -1) {
        tags.push(added.text);
      }
    });
  })();

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
      var attachments = $('#attachment_data').attr('data');
      $.post(
          "/preview",
          { bodyText: bodyText,
            attachments: attachments
          },
          function(data) {
              $('.govspeak').html(data);
          }
      );
      return false;
  });
});
