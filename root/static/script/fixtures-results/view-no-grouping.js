/**
 *  Initialise datatable
 *
 */
$(document).ready(function() {
  $("#fixtures-table").DataTable({
    "responsive": true,
    "paging": true,
    "pageLength": 25,
    //pagingType: "full_numbers",
    "lengthChange": true,
    "lengthMenu": [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]],
    "info": true,
    "fixedHeader": true,
    "searching": true,
    "ordering": true,
    "order": [[1, "asc"]],
    "columnDefs": [{
      // Date sortable
      "visible": false,
      "targets": 0
    }, {
      // Date printable
      "responsivePriority": 1,
      "orderData": 0,
      "targets": 1
    }, {
      // Home team
      "responsivePriority": 2,
      "targets": 2
    }, {
      // Away team
      "responsivePriority": 3,
      "targets": 3
    }, {
      // Score
      "responsivePriority": 4,
      "targets": 4
    }/*, {
      // Venue
      "responsivePriority": 6,
      "targets": 9
    }*/]
  });
  
  $("select[name=fixtures-table_length]").chosen({
    disable_search: true,
    single_backstroke_delete: false,
    allow_single_deselect: true
  });
});