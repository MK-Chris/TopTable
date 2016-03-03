/**
 *  Handle form fields
 *
 */
$(document).ready(function() {
  /*
    Dialog box for confirming we wish to change the team for a player who has played for the team they're already registered for
  */
  $( "#dialog" ).dialog({
    autoOpen: false,
    modal: true,
    resizable: false,
    width: 600,
    open: function (e, ui) {
        $(this).parent().find(".ui-dialog-buttonpane .ui-button").addClass("button");
    },
    buttons: [{
      text: "Yes", click: function() {
        $("#person-team-not-editable").hide();
        $("#person-team-editable").show();
        $(this).dialog("close");
      }
    }, {
      text: "No", click: function() {
        $(this).dialog("close");
      }
    }],
  });
  
  $("#change_team").on("click", function() {
    $("#dialog").dialog("open");
  });
  
  /*
    Focus on the first available field
  */
  if ( $("#first_name").val() == "" ) {
    $("#first_name").focus();
  } else if ( $("#surname").val() === "" ) {
    $("#surname").focus();
  } else if ( $("#address1").val() === "" ) {
    $("#address1").focus();
  } else if ( $("#address2").val() === "" ) {
    $("#address2").focus();
  } else if ( $("#address3").val() === "" ) {
    $("#address3").focus();
  } else if ( $("#address4").val() === "" ) {
    $("#address4").focus();
  } else if ( $("#address5").val() === "" ) {
    $("#address5").focus();
  } else if ( $("#postcode").val() === "" ) {
    $("#postcode").focus();
  } else if ( $("#home_telephone").val() === "" ) {
    $("#home_telephone").focus();
  } else if ( $("#mobile_telephone").val() === "" ) {
    $("#mobile_telephone").focus();
  } else if ( $("#work_telephone").val() === "" ) {
    $("#work_telephone").focus();
  } else if ( $("#email_address").val() === "" ) {
    $("#email_address").focus();
  } else if ( $("#date_of_birth").val() === "" ) {
    $("#date_of_birth").focus();
  } else if ( $("#token-input-team").val() === "" ) {
    $("#token-input-team").focus();
  } else if ( $("#registration_date").val() === "" ) {
    $("#registration_date").focus();
  } else if ( $("#token-input-website_username").val() === "" ) {
    $("#token-input-website_username").focus();
  } else {
    // Default back to full name
    $("#first_name").focus();
  }
});