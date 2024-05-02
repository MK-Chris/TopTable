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
    "order": [[1, "asc"], [2, "asc"]],
    "rowGroup": {
      "dataSrc": 2
    },
    "columnDefs": [{
      // Date sortable, division rank
      "visible": false,
      "targets": [0, 3]
    }, {
      // Date printable
      "responsivePriority": 1,
      "orderData": 0,
      "targets": 1
    }, {
      // Division name
      "responsivePriority": 3,
      "orderData": 3,
      "targets": 2
    }, {
      // Home team
      "responsivePriority": 1,
      "targets": 4
    }, {
      // Away team
      "responsivePriority": 2,
      "targets": 5
    }, {
      // Score
      "responsivePriority": 4,
      "targets": 4
    }]
  });
  
  $("select[name=fixtures-table_length]").chosen({
    disable_search: true,
    single_backstroke_delete: false,
    allow_single_deselect: true,
    width: "75px"
  });
});