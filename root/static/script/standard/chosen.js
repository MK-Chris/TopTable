  
  $(document).ready(function(){    
    $("select").not("select.doubles, select.time, select.player-number, select.grid-match, select.average-filter, select.average-filter-pre-defined").chosen({
      single_backstroke_delete: false,
      allow_single_deselect: true,
      width: "100%"
    });
    
    $("select.time").chosen({
      single_backstroke_delete: false,
      allow_single_deselect: true,
      width: "75px"
    });
    
    $("select.player-number").chosen({
      single_backstroke_delete: false,
      allow_single_deselect: true,
      width: "80px"
    });
    
    $("select.doubles").chosen({
      single_backstroke_delete: false,
      allow_single_deselect: true,
      max_selected_options: 2,
      width: "100%"
    });
    
    $("select.grid-match").chosen({
      single_backstroke_delete: false,
      allow_single_deselect: true,
      width: "120px"
    });
    
    $("select.average-filter").chosen({
      single_backstroke_delete: false,
      allow_single_deselect: true,
      width: "90px"
    });
    
    $("select.average-filter-pre-defined").chosen({
      single_backstroke_delete: false,
      allow_single_deselect: true,
      width: "auto"
    });
  });
  