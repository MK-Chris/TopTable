$(document).ready(function(){    
  /*
   Checkbox / radio button replacements
  */
  $("#round_week_commencing").prettyCheckable({
    labelPosition: "left",
      customClass: "wb"
  });
  
  $("#round_week_commencing").on("change", function() {
    var $this = $(this);
    if ( $this.prop("checked") ) {
      $("#round_date").val("");
    }
  });
  
  $("#round_date").datepicker({
    dateFormat: "dd/mm/yy",
    firstDay: 1,
    changeMonth: true,
    changeYear: true,
    beforeShowDay: function(date) {
      if ( $("#round_week_commencing").prop("checked") ) {
        // Only enable Mondays in the date picker if the 'week beginning' flag is ticked
        var day = date.getDay();
        return [(day == 1), ""];
      } else {
        console.log("enable all days");
        return [1, ""];
      }
    }
  });
});