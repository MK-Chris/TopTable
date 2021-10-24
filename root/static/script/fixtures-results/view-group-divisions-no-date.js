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
    "lengthMenu": [ [10, 25, 50, 100, -1], [10, 25, 50, 100, "All"] ],
    "info": true,
    "fixedHeader": true,
    "searching": true,
    "order": [[1, "asc"]],
    "ordering": false,
    "rowGroup": {
      "dataSrc": 0
    },
    "columnDefs": [{
      // Division rank, division name
      "visible": false,
      "targets": [0, 1]
    }, {
      // Division name
      "orderData": 1,
      "targets": 0
    }, {
      // Home team
      "responsivePriority": 1,
      "targets": 2
    }, {
      // Away team
      "responsivePriority": 2,
      "targets": 3
    }, {
      // Score
      "responsivePriority": 3,
      "targets": 4
    }, {
      // Venue
      "responsivePriority": 4,
      "targets": 5
    }]
  });
  
  $("select[name=fixtures-table_length]").chosen({
    disable_search: true,
    single_backstroke_delete: false,
    allow_single_deselect: true
  });
});