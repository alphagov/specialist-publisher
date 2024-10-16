//= require jquery
//= require select2
//= require dropdown_select_all
//= require length_counter
//= require form_change_protection

jQuery(function ($) {
  var token = $('meta[name="csrf-token"]').attr('content')

  $.ajaxSetup({
    beforeSend: function (xhr) {
      xhr.setRequestHeader('X-CSRF-Token', token)
    }
  })

  $('.select2').select2({
    placeholder: $(this).data('placeholder')
  })

  /// /
  // Add "select all"/"clear all" buttons to each select2 dropdown menu
  // but exclude those that aren't for multiple selection
  var dropdownSelectAll = new GOVUKAdmin.Modules.DropdownSelectAll()
  dropdownSelectAll.init($('select.select2[multiple]').not('.select-all-disabled'))
  var dropdownClearAll = new GOVUKAdmin.Modules.DropdownClearAll()
  dropdownClearAll.init($('select.select2[multiple]').not('.clear-all-disabled'));

  /// /
  // Make a select2 that will create new values on return as you type them
  (function () {
    var element = $('.free-form-list')
    if (element.length === 0) return

    var value = element.val()
    var tags = (value === '') ? [] : value.split('::')

    element.select2({
      tags: tags,
      separator: '::'
    }).on('change', function (event) {
      var added = event.added

      if (typeof added !== 'undefined' && tags.indexOf(added.text) === -1) {
        tags.push(added.text)
      }
    })
  })()

  $('.js-hidden').hide()

  $('.js-update-type-major').click(function () {
    $('.js-change-note').show()
  })

  $('.js-update-type-minor').click(function () {
    $('.js-change-note').hide()
  })

  $('.js-length-counter').each(function () {
    new GOVUK.LengthCounter({ $el: $(this) }) // eslint-disable-line no-new
  })

  $('#preview-button').click(function () {
    $('.preview_container').removeClass('hide')
    var bodyText = $('.body-text').val()
    var attachments = $('#attachment_data').attr('data')
    $.post(
      '/preview',
      {
        bodyText: bodyText,
        attachments: attachments
      },
      function (data) {
        $('.govspeak').html(data)
      }
    )
    return false
  })
})
