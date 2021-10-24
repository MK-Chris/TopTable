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
    "order": [4, "asc"],
    "ordering": true,
    "rowGroup": {
      "dataSrc": 4
    },
    "columnDefs": [{
      // Day of week number, date sortable, division name (used in group), division rank
      "visible": false,
      "targets": [1, 3, 4, 5]
    }, {
      // Date printable
      "responsivePriority": 1,
      "orderData": 3,
      "targets": 2
    }, {
      // Home team
      "responsivePriority": 2,
      "targets": 6
    }, {
      // Away team
      "responsivePriority": 3,
      "targets": 7
    }, {
      // Score
      "responsivePriority": 4,
      "targets": 8
    }, {
      // Division name
      "responsivePriority": 5,
      "orderData": 5,
      "targets": 4
    }/*, {
      // Venue
      "responsivePriority": 6,
      "targets": 9
    }*/, {
      // Day name
      "responsivePriority": 7,
      "targets": 0
    }]
  });
  
  $("select[name=fixtures-table_length]").chosen({
    disable_search: true,
    single_backstroke_delete: false,
    allow_single_deselect: true
  });
});