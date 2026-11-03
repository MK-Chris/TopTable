/**
 *  Initialise datatable
 *
 */
$(document).ready(function() {
  let isMobile = window.matchMedia("(max-width: 767px)").matches;
  
  $("#averages-doubles-individuals").DataTable({
    responsive: true,
    paging: false,
    info: false,
    ordering: false,
    fixedHeader: isMobile ? false : true,
    searching: false,
    columns: [
      {responsivePriority: 1},
      {responsivePriority: 2},
      {responsivePriority: 7},
      {responsivePriority: 4},
      {responsivePriority: 5},
      {responsivePriority: 6},
      {responsivePriority: 3}
    ]
  });
});