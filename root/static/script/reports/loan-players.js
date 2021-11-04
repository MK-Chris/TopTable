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
    "lengthMenu": [ [10, 25, 50, 100, -1], [10, 25, 50, 100, "All"] ],
    "info": true,
    "fixedHeader": true,
    "colReorder": {
      "fixedColumnsLeft": 1
    },
    "rowGroup": {
      "enable": false,
      "dataSrc": 0,
      "startRender": function (rows, group) {
        var rowsText;
        
        if (rows.count() == 1) {
          rowsText = "row";
        } else {
          rowsText = "rows";
        }
        
        return group + " (" + rows.count() + " " + rowsText + ")";
      }
    },
    "columnDefs": [{
      "visible": false,
      "targets": [4, 6, 9, 11]
    }, {
      "orderData": 4,
      "targets": 3
    }, {
      "orderData": 6,
      "targets": 5
    }, {
      "orderData": 9,
      "targets": 8
    }, {
      "orderData": 11,
      "targets": 10
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
    report_table.column($previous_value).visible(true);
    
    if ( $this.val() === "" ) {
      // No grouping, disable grouping and redraw the table
      report_table.columns.adjust();
      report_table.rowGroup().disable().draw();
    } else {
      // Group by select value's column index
      report_table.column( $this.val() ).visible(false);
      report_table.columns.adjust();
      report_table.rowGroup().dataSrc( $this.val() );
      report_table.rowGroup().enable().draw();
    }
    
    // Set the previous value
    $this.data("previous-value", $this.val());
  });
});