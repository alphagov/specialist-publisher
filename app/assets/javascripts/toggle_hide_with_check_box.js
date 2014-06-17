(function(window, $){
  window.toggleHideWithCheckBox = function(args){
    var $checkBox = args.$checkBox;
    var $elementToHide = args.$elementToHide;

    var toggleHideOnChange = function(){
      if($checkBox.prop("checked")) {
        $elementToHide.hide();
      }
      else {
        $elementToHide.show();
      }
    }

    $checkBox.change(toggleHideOnChange);
  };
})(window, $);
