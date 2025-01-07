/**
 *  Initialise datatable
 *
 */
$(document).ready(function() {
  $("#fixtures-table").DataTable({
    responsive: true,
    paging: true,
    pageLength: 25,
    lengthChange: true,
    lengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]],
    info: true,
    fixedHeader: true,
    searching: true,
    ordering: true,
    order: [[3, "asc"]],
    columnDefs: [{
      // Day of week sortable, date sortable, competition sortable
      visible: false,
      targets: [0, 2, 4]
    }, {
      // Day of week
      responsivePriority: 6,
      orderData: 0,
      targets: 1
    }, {
      // Date
      responsivePriority: 3,
      orderData: 2,
      targets: 3
    }, {
      // Competition
      responsivePriority: 5,
      orderData: 4,
      targets: 5
    }, {
      // Home team
      responsivePriority: 1,
      targets: 6
    }, {
      // Away team
      responsivePriority: 2,
      targets: 7
    }, {
      // Score
      responsivePriority: 4,
      orderable: false,
      targets: 8
    }, {
      // Venue
      responsivePriority: 7,
      targets: 9
    }]
  });
  
  $("select[name=fixtures-table_length]").chosen({
    disable_search: true,
    single_backstroke_delete: false,
    allow_single_deselect: true,
    width: "75px"
  });
});