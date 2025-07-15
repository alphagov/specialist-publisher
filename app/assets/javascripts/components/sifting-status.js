'use strict'

window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {}

;(function (Modules) {
  function SiftingStatus (module) {
    this.module = module
  }

  SiftingStatus.prototype.init = function () {
    this.siftingStatusSelect = this.module.querySelector('#statutory_instrument_sifting_status')
    this.withdrawnDateWrapper = this.module.querySelector('.withdrawn-date-wrapper')
    this.withdrawnDateFields = this.module.querySelectorAll('input[id^="statutory_instrument_withdrawn_date"]')
    this.siftEndDateFields = this.module.querySelectorAll('input[id^="statutory_instrument_sift_end_date"]')

    this.siftingStatusSelect.addEventListener('change', this.handleChange.bind(this))
  }

  SiftingStatus.prototype.handleChange = function (event) {
    if (event.target.value === 'withdrawn') {
      this.withdrawnDateWrapper.style.display = 'block'
      for (var i = 0; i < this.siftEndDateFields.length; i++) {
        this.siftEndDateFields[i].value = ''
      }
    } else {
      this.withdrawnDateWrapper.style.display = 'none'
      for (i = 0; i < this.withdrawnDateFields.length; i++) {
        this.withdrawnDateFields[i].value = ''
      }
    }
  }

  Modules.SiftingStatus = SiftingStatus
})(window.GOVUK.Modules)
