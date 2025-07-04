'use strict'
window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {}
;(function (Modules) {
  function GovspeakEditor (module) {
    this.module = module
  }

  GovspeakEditor.prototype.init = function () {
    this.previewButton = this.module.querySelector(
      '.js-app-c-govspeak-editor__preview-button'
    )
    this.backButton = this.module.querySelector(
      '.js-app-c-govspeak-editor__back-button'
    )
    this.preview = this.module.querySelector('.app-c-govspeak-editor__preview')
    this.error = this.module.querySelector('.app-c-govspeak-editor__error')
    this.textareaWrapper = this.module.querySelector(
      '.app-c-govspeak-editor__textarea'
    )
    this.textarea = this.textareaWrapper.querySelector('textarea')

    this.previewButton.classList.add(
      'app-c-govspeak-editor__preview-button--show'
    )
    this.attachmentsData = this.module.querySelector('.app-c-govspeak-editor__preview-button-wrapper > #attachment_data').getAttribute('data')

    this.previewButton.addEventListener('click', this.showPreview.bind(this))
    this.backButton.addEventListener('click', this.hidePreview.bind(this))
  }

  GovspeakEditor.prototype.getCsrfToken = function () {
    return document.querySelector('meta[name="csrf-token"]').content
  }

  GovspeakEditor.prototype.getRenderedGovspeak = function (body, attachments, callback) {
    const data = this.generateFormData(body, attachments)

    const request = new XMLHttpRequest()
    request.open('POST', '/preview', true)
    request.setRequestHeader('X-CSRF-Token', this.getCsrfToken())
    request.onreadystatechange = callback
    request.send(data)
  }

  GovspeakEditor.prototype.generateFormData = function (body, attachments) {
    const data = new FormData()
    data.append('bodyText', body)
    data.append('attachments', attachments)
    data.append('authenticity_token', this.getCsrfToken())
    return data
  }

  GovspeakEditor.prototype.showPreview = function (event) {
    event.preventDefault()

    this.backButton.classList.add('app-c-govspeak-editor__back-button--show')
    this.previewButton.classList.remove(
      'app-c-govspeak-editor__preview-button--show'
    )

    this.preview.innerHTML = '<p class="govuk-body">Generating preview, please wait...</p>'
    this.preview.classList.add('app-c-govspeak-editor__preview--show')
    this.textareaWrapper.classList.add(
      'app-c-govspeak-editor__textarea--hidden'
    )

    this.backButton.focus()

    this.getRenderedGovspeak(this.textarea.value, this.attachmentsData, (event) => {
      const response = event.currentTarget

      if (response.readyState !== 4) {
        return
      }

      switch (response.status) {
        case 200:
          this.preview.innerHTML = response.responseText
          break
        case 403:
          this.preview.classList.remove('app-c-govspeak-editor__preview--show')
          this.error.classList.add('app-c-govspeak-editor__error--show')
      }
    })
  }

  GovspeakEditor.prototype.hidePreview = function (event) {
    event.preventDefault()

    this.backButton.classList.remove('app-c-govspeak-editor__back-button--show')
    this.previewButton.classList.add(
      'app-c-govspeak-editor__preview-button--show'
    )

    this.preview.classList.remove('app-c-govspeak-editor__preview--show')
    this.error.classList.remove('app-c-govspeak-editor__error--show')
    this.textareaWrapper.classList.remove(
      'app-c-govspeak-editor__textarea--hidden'
    )

    this.textarea.focus()
  }

  Modules.GovspeakEditor = GovspeakEditor
})(window.GOVUK.Modules)
