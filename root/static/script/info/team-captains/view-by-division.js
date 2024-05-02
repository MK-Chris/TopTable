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
    "orderFixed": [1, "asc"],
    "ordering": true,
    "rowGroup": {
      "dataSrc": 1
    },
    "columnDefs": [{
      // Hide columns position order, committee position (without admin links), sortable name
      "visible": false,
      "targets": [0, 1, 3]
    }, {
      "orderData": 0,
      "targets": 1
    }, {
      "orderData": 3,
      "targets": 4
    }]
  });
  
  $("select[name=datatable_length]").chosen({
    disable_search: true,
    single_backstroke_delete: false,
    allow_single_deselect: true,
    width: "75px"
  });
});
