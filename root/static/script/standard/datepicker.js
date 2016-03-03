$(document).ready(function(){    
  $("input.date_picker").datepicker({
    dateFormat: "dd/mm/yy",
    firstDay: 1,
    changeMonth: true,
    changeYear: true
  });
});