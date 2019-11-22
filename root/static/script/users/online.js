$(document).ready(function(){
  /**
   *  Initialise datatables
   *
   */
  $("#datatable").DataTable({
    "responsive": true,
    "paging": false,
    "info": false,
    "fixedHeader": true,
    "columnDefs": [{
      "visible": false,
      "targets": 6
    }, {
      "orderData": 6,
      "targets": 5
    }]
  });
});
