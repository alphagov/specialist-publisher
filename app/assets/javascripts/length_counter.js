(function($) {
  "use strict";
  window.GOVUK = window.GOVUK || {};

  function LengthCounter(options){
    this.$input = $(options.$el);

    if(this.$input.length > 0){
      this.$input.on('keyup', $.proxy(this.checkLength, this))
      this.$message = $(this.$input.data('countMessageSelector'));
      this.$count = this.$message.find('.count');
      this.threshold = this.$input.data('countMessageThreshold');
      this.hideMessage();
      this.$input.addClass('length-input');
    } else {
      return;
    }
  }

  LengthCounter.prototype.checkLength = function() {
    var length = this.$input.val().length;
    this.$count.text('Current length: '+length);
    
    if (length > this.threshold) {
      this.addWarningClass();
      this.showMessage();
    } else {
      this.removeWarningClass();
    }
  };

  LengthCounter.prototype.showMessage = function() {
    this.$message.show();
  };

  LengthCounter.prototype.hideMessage = function() {
    this.$message.hide();
  };

  LengthCounter.prototype.addWarningClass = function() {
    this.$input.addClass('warning');
    this.$message.addClass('warning');
  };

  LengthCounter.prototype.removeWarningClass = function() {
    this.$input.removeClass('warning');
    this.$message.removeClass('warning');
  };

  GOVUK.LengthCounter = LengthCounter;

}(jQuery));
