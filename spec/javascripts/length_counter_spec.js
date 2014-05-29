describe('LengthCounter', function() {

  var $fieldHtml, $warningHtml, field, long_text;

  beforeEach(function() {
    $fieldHtml = $("<textarea class='short-textarea js-length-counter length-input'" +
              "cols='40' data-count-message-selector='.summary-length-info'" +
              "data-count-message-threshold='280' id='manual_summary'" +
              "name='manual[summary]' rows='20'></textarea>");

    $warningHtml = $("<div class='summary-length-info' aria-live='polite'" +
                  ">Summary text should be 280 characters or fewer. <span class='count'></span></div>");

    $('body').append($fieldHtml);
    $('body').append($warningHtml);

    field = new GOVUK.LengthCounter({$el: $fieldHtml});

    long_text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse faucibus sit" +
    "amet eros sed placerat. Phasellus adipiscing massa sit amet enim auctor laoreet. Aliquam erat" + 
    "volutpat. Curabitur posuere, lorem in condimentum semper, odio lectus tempor est, viverra" + 
    "egestas metus. Lorem ipsum dolor sit amet.";
  });

  afterEach(function(){
    $fieldHtml.remove();
    $warningHtml.remove();
  });

  describe('#init', function() {

    it("should check that the warning message is hidden", function() {
      expect($(".summary-length-info:visible").length).toBe(0);
    });

  });

  describe('when the threshold is passed', function() {

    beforeEach(function() {
      field.$input.val(long_text);
      field.$input.keyup();
    });

    it("should check that the warning message appears", function() {
      expect($(".summary-length-info:visible").length).toBe(1);
    });

    it("should display the amount of characters", function() {
      expect(field.$count.text()).toBe("Current length: 305");
    });
  });

  describe('when characters are deleted after the threshold has been passed', function() {

    beforeEach(function() {
      field.$input.val(long_text);
      field.$input.keyup();
      field.$input.val(long_text.slice(0, 140))
      field.$input.keyup();
    });

    it("should still display the warning with an updated count", function() {
      expect($(".summary-length-info:visible").length).toBe(1);
      expect(field.$count.text()).toBe("Current length: 140");
    });

  });

});
