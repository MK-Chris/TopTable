$(document).ready(function(){    
  /*
   Checkbox / radio button replacements
  */
  $("input[type=checkbox],input[type=radio]").not("input.button-toggle, input.nav").each(function(){
    $(this).prettyCheckable({
      labelPosition: "left",
      customClass: "label-field-container"
    });
  });
});