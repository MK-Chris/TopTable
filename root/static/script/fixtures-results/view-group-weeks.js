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
    "ordering": false,
    "rowGroup": {
      "dataSrc": 0
    },
    "columnDefs": [{
      // Week beginning
      "visible": false,
      "targets": 0
    }, {
      // Division name
      "responsivePriority": 4,
      "targets": 1
    }, {
      // Home team
      "responsivePriority": 1,
      "targets": 3
    }, {
      // Away team
      "responsivePriority": 2,
      "targets": 4
    }, {
      // Score
      "responsivePriority": 3,
      "targets": 5
    }, {
      // Venue
      "responsivePriority": 5,
      "targets": 5
    }]
  });
  
  $("select[name=fixtures-table_length]").chosen({
    disable_search: true,
    single_backstroke_delete: false,
    allow_single_deselect: true
  });
});