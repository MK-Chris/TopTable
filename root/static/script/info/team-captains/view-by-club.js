/**
 *  Initialise datatable
 *
 */
$(document).ready(function() {
  $("#datatable").DataTable({
    "responsive": true,
    "paging": true,
    "pageLength": 25,
    //pagingType: "full_numbers",
    "lengthChange": true,
    "lengthMenu": [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]],
    "info": true,
    "fixedHeader": true,
    "orderFixed": [0, "asc"],
    "ordering": true,
    "rowGroup": {
      "dataSrc": 0
    },
    "columnDefs": [{
      // Hide columns club (because we're grouping by that) and division rank
      "visible": false,
      "targets": [0, 2, 4]
    }, {
      "orderData": 2,
      "targets": 3
    }, {
      "orderData": 4,
      "targets": 5
    }]
  });
  
  $("select[name=datatable_length]").chosen({
    disable_search: true,
    single_backstroke_delete: false,
    allow_single_deselect: true
  });
});
