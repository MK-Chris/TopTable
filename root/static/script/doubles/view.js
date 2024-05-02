/**
 *  Initialise datatable
 *
 */
$(document).ready(function() {
  var games = $("#games_table").DataTable({
    "responsive": true,
    "paging": true,
    "pageLength": 25,
    "lengthChange": true,
    "lengthMenu": [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]],
    "info": true,
    "fixedHeader": true,
    "layout": {
      "topStart": "pageLength",
      "topEnd": "search",
      "bottomStart": "info",
      "bottomEnd": "paging",
      "bottom2Start": "searchPanes"
    },
    "searchPanes": {
      "layout": "columns-6",
      "collapse": false,
      "clear": false,
      "dtOpts": {
        "select": {style: "multi"}
      }
    },
    "language": {
      "searchPanes": {
        "emptyPanes": null,
        "title": $("#dt-data-only").data("dt-filter")
      }
    },
    "columnDefs": [{
      // Date display
      "orderData": 1,
      "responsivePriority": 5,
      "searchPanes": {"show": false},
      "targets": 0
    }, {
      // Date sortable
      "visible": false,
      "responsivePriority": 5,
      "searchPanes": {"show": false},
      "targets": 1
    }, {
      // Playing for (team)
      "responsivePriority": 7,
      "searchPanes": {"show": false},
      "targets": 2
    }, {
      // Playing against (team)
      "responsivePriority": 6,
      "searchPanes": {"show": false},
      "targets": 3
    }, {
      // Opponents (doubles pair)
      "responsivePriority": 2,
      "searchPanes": {"show": false},
      "targets": 4
    }, {
      // Score
      "orderable": false,
      "responsivePriority": 4,
      "searchPanes": {"show": false},
      "targets": 5
    }, {
      // Result
      "orderable": false,
      "responsivePriority": 3,
      "searchPanes": {"show": false},
      "targets": 6
    }, {
      // Membership type
      "visible": false,
      "searchPanes": {
        //"show": true,
        "controls": false
      },
      "targets": 7
    }]
  });
  
  $("select[name=games_table_length]").chosen({
    disable_search: true,
    single_backstroke_delete: false,
    allow_single_deselect: true,
    width: "75px"
  });
  
  /*
    Responsive tabs
  */
  $("div#tabs").responsiveTabs({
    startCollapsed: false,
    setHash: false,
    activate: function(event, tab) {
      if ( tab.selector == "#games" ) {
        // Redraw singles games table
        games.responsive.recalc();
      }
    }
  });
});