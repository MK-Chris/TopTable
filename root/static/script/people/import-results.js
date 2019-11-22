$(document).ready(function(){
  /**
   *  Initialise datatables
   *
   */
  $("#failed-imports, #successful-imports").DataTable({
    "responsive": true,
    "paging": true,
    "info": true,
    "ordering": true,
    "fixedHeader": true,
    "searching": true
  });
});
