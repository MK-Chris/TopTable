/**
 *  Initialise datatable
 *
 */
$(document).ready(function() {
  var report_table = $("#report").DataTable({
    "responsive": true,
    "paging": true,
    "pageLength": 25,
    //pagingType: "full_numbers",
    "lengthChange": true,
    "lengthMenu": [[10, 25, 50, 100, -1], [10, 25, 50, 100, $("#dt-lang").data("dt-paging-all")]],
    "info": true,
    "fixedHeader": true,
    "colReorder": true,
    "rowGroup": {
      "enable": false,
      "dataSrc": 0,
      "startRender": function (rows, group) {
        var rowsText;
        
        if (rows.count() == 1) {
          rowsText = $("#dt-lang").data("dt-rows-singular");
        } else {
          rowsText = $("#dt-lang").data("dt-rows-plural");
        }
        
        return group + " (" + rows.count() + " " + rowsText + ")";
      }
    },
    "columnDefs": [{
      "visible": false,
      "targets": [0, 2] // Sortable date, division rank
    }, {
      // Date
      "orderData": 0,
      "responsivePriority": 5,
      "targets": 1
    }, {
      // Division
      "orderData": 2,
      "responsivePriority": 3,
      "targets": 3
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
      "orderable": false,
      "targets": 6
    }, {
      // Venue
      "responsivePriority": 6,
      "targets": 7
    }]
  });
  
  $("select").chosen({
    disable_search: true,
    single_backstroke_delete: false,
    allow_single_deselect: true
  });
  
  /*
    Put the checkbox inside the table div.
  */
  $("#report-grouper").prependTo("#report_wrapper");
  
  /*
    Handle chosen selectbox change
  */
  $("#group-table").on("change", function() {
    var $this = $(this);
    
    // Set the previous column to visible.
    var $previous_value = $this.data("previous-value");
    if ( $previous_value !== "" ) report_table.column($previous_value).visible(true);
    
    if ( $this.val() === "" ) {
      // No grouping, disable grouping and redraw the table
      report_table.columns.adjust();
      report_table.rowGroup().disable().draw();
      
      // The fixed order is now also removed so that we don't just order within the group
      report_table.order.fixed([]);
    } else {
      // Group by select value's column index
      report_table.column($this.val()).visible(false);
      report_table.columns.adjust();
      report_table.order.fixed({"pre": [$this.val(), "asc"]});
      report_table.rowGroup().dataSrc($this.val());
      report_table.rowGroup().enable().draw();
    }
    
    // Set the previous value
    $this.data("previous-value", $this.val());
  });
});