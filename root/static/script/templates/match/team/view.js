$(document).ready(function(){
  /**
   *  Initialise datatables
   *
   */
  $("#datatable").DataTable({
    "responsive": true,
    "paging": false,
    "info": true,
    "ordering": false,
    "fixedHeader": true,
    "searching": false
  });
});
