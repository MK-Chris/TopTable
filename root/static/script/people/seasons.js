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
    "columnDefs": [{
      "visible": false,
      "targets": [0, 2, 5]
    }, {
      // Season
      "orderData": 0,
      "targets": 1
    }, {
      // Person name
      "orderData": 3,
      "targets": 2
    }, {
      // Division
      "orderData": 5,
      "targets": 6
    }]
  });
  
  $("select[name=datatable_length]").chosen({
    disable_search: true,
    single_backstroke_delete: false,
    allow_single_deselect: true,
    width: "75px"
  });
});
