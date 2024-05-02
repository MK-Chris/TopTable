/**
 *  Format the response messages.  If there's an array of more than one element, this is converted to an HTML list; otherwise, it's returned as-is.
 *
 */
function format_response_messages(messages) {
  var display_message = "";
  
  if ( Array.isArray(messages) === false ) {
    return messages;
  }
  
  switch ( messages.length ) {
    case 0:
      // Nothing to return, no elements in the array
      break;
    case 1:
      // A single thing to display, just return the text
      display_message = messages[0];
      break;
    default:
      // More than one item in the array, loop through and add them to a list
      display_message = "<ul>\n";
      
      $.each(messages, function(index, value) {
        display_message += "  <li>" + value + "</li>\n";
      });
      
      display_message += "</ul>\n";
  }
  
  return display_message;
} // Enf of format_response_messages()

/**
 *  Show the response messages (of type error, warning, info and success) as a toast message.
 *  Errors and warnings are sticky (so stay until dismissed), whereas info and success disappear after a few seconds.
 *
 */
function show_messages(response) {
  let success_message = format_response_messages(response.messages.success);
  let error_message = format_response_messages(response.messages.error);
  let warning_message = format_response_messages(response.messages.warning);
  let info_message = format_response_messages(response.messages.info);
  
  if ( typeof success_message !== "undefined" && success_message !== "" ) {
    $().toastmessage("showToast", {
      text: "<br />" + success_message,
      sticky: false,
      position: "top-center",
      type: "success"
    });
  }
  
  if ( typeof error_message !== "undefined" && error_message !== "" ) {
    $().toastmessage("showToast", {
      text: "<br />" + error_message,
      sticky: true,
      position: "top-center",
      type: "error"
    });
  }
  
  if ( typeof warning_message !== "undefined" && warning_message !== "" ) {
    $().toastmessage("showToast", {
      text: "<br />" + warning_message,
      sticky: true,
      position: "top-center",
      type: "warning"
    });
  }
  
  if ( typeof info_message !== "undefined" && info_message !== "" ) {
    $().toastmessage("showToast", {
      text: "<br />" + info_message,
      sticky: false,
      position: "top-center",
      type: "info"
    });
  }
} // End of show_messages()