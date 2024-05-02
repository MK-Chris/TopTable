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
    "order": [1, "desc"],
    "ordering": false,
    "rowGroup": {
      "dataSrc": 1
    },
    "columnDefs": [{
      // Hide columns position order, committee position (without admin links), sortable name
      "visible": false,
      "targets": [0, 1, 2]
    }, {
      "orderData": 1,
      "targets": 0
    }]
  });
  
  $("select[name=datatable_length]").chosen({
    disable_search: true,
    single_backstroke_delete: false,
    allow_single_deselect: true,
    width: "75px"
  });
});
