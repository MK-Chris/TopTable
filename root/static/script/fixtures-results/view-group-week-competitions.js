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
    "orderFixed": {
      "pre": [[4, "asc"], [6, "asc"]]
    },
    "order": [0, "asc"],
    "ordering": true,
    "rowGroup": {
      "dataSrc": [4, 6]
    },
    "columnDefs": [{
      /*
        1= Weekday sortable
        3 = date sortable
        4 = week beginning (used in group)
        5 = week beginning sortable
        6 = competitions name (used in group)
        7 = competition sort
      */
      "visible": false,
      "targets": [1, 3, 4, 5, 6, 7]
    }, {
      // Day name
      "responsivePriority": 6,
      "orderData": 1,
      "targets": 0
    }, {
      // Date printable
      "responsivePriority": 1,
      "orderData": 3,
      "targets": 2
    }, {
      // Week beginning
      "orderData": 5,
      "targets": 4
    }, {
      // Competition
      "orderData": 7,
      "targets": 6
    }, {
      // Home team
      "responsivePriority": 2,
      "targets": 8
    }, {
      // Away team
      "responsivePriority": 3,
      "targets": 9
    }, {
      // Score
      "responsivePriority": 4,
      "orderable": false,
      "targets": 10
    }, {
      // Venue
      "responsivePriority": 5,
      "targets": 11
    }]
  });
  
  $("select[name=fixtures-table_length]").chosen({
    disable_search: true,
    single_backstroke_delete: false,
    allow_single_deselect: true,
    width: "75px"
  });
});