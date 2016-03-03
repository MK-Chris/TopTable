    
    
    /*
      Froala WYSIWYG
    */
    $("textarea").editable({
      buttons: ["undo", "redo", "bold", "italic", "underline", "strikeThrough", "subscript", "superscript", "fontFamily", "fontSize", "color", "table", "insertHorizontalRule", "removeFormat", "sep", "formatBlock", "blockStyle", "inlineStyle", "align", "insertOrderedList", "insertUnorderedList", "outdent", "indent", "selectAll", "sep", "createLink", "insertImage", "insertVideo", "uploadFile", "sep", "html"],
      inlineMode: false,
      theme: "gray",
      defaultImageAlignment: "right",
      defaultImageDisplay: "inline",
      paragraphy: false,
      imageUploadURL: "[% c.uri_for("/image/upload") %]",
      imageUploadParam: "file",
      imageUploadParams: {
        type: $("#file_upload_type").val()
      },
      fileUploadURL: "[% c.uri_for("/file/upload") %]",
      fileUploadParam: "file",
      fileUploadParams: {
        type: $("#file_upload_type").val()
      }
    }).on({
      "editable.imageError": function (e, editor, error) {
        if (error.code == 0) {
          // Custom error message returned from the server.
          $().toastmessage("showToast", {
            text: "Error: " + error + ".",
            sticky: false,
            position: "top-center",
            type: "error"
          });
        } else if (error.code == 1) {
          // Bad link.
          $().toastmessage("showToast", {
            text: "Error, bad link: " + error.message + ".",
            sticky: false,
            position: "top-center",
            type: "error"
          });
        } else if (error.code == 2) {
          // No link in upload response.
          $().toastmessage("showToast", {
            text: "Error, no image path provided in response: " + error + ".",
            sticky: false,
            position: "top-center",
            type: "error"
          });
        } else if (error.code == 3) {
          // Error during image upload.
          $().toastmessage("showToast", {
            text: "Error uploading: " + error.message + ".",
            sticky: false,
            position: "top-center",
            type: "error"
          });
        } else if (error.code == 4) {
          // Parsing response failed.
          $().toastmessage("showToast", {
            text: "Error, couldn't parse response: " + error.message + ".",
            sticky: false,
            position: "top-center",
            type: "error"
          });
        } else if (error.code == 5) {
          // Image too large.
          $().toastmessage("showToast", {
            text: "Error, image file too large: " + error.message + ".",
            sticky: false,
            position: "top-center",
            type: "error"
          });
        } else if (error.code == 6) {
          // Invalid image type.
          $().toastmessage("showToast", {
            text: "Error, invalid image type: " + error.message + ".",
            sticky: false,
            position: "top-center",
            type: "error"
          });
        } else if (error.code == 7) {
          // Image can be uploaded only to same domain in IE 8 and IE 9.
          $().toastmessage("showToast", {
            text: "Error, cannot upload to a different domain in your browser: " + error.message + ".",
            sticky: false,
            position: "top-center",
            type: "error"
          });
        }
      },
      "editable.fileError": function (e, editor, error) {
        if (error.code == 0) {
          // Custom error message returned from the server.
          $().toastmessage("showToast", {
            text: "Error: " + error.message + ".",
            sticky: false,
            position: "top-center",
            type: "error"
          });
        } else if (error.code == 1) {
          // Bad link.
          $().toastmessage("showToast", {
            text: "Error, bad link: " + error.message + ".",
            sticky: false,
            position: "top-center",
            type: "error"
          });
        } else if (error.code == 2) {
          // No link in upload response.
          $().toastmessage("showToast", {
            text: "Error, no image path provided in response: " + error.message + ".",
            sticky: false,
            position: "top-center",
            type: "error"
          });
        } else if (error.code == 3) {
          // Error during image upload.
          $().toastmessage("showToast", {
            text: "Error uploading: " + error.message + ".",
            sticky: false,
            position: "top-center",
            type: "error"
          });
        } else if (error.code == 4) {
          // Parsing response failed.
          $().toastmessage("showToast", {
            text: "Error, couldn't parse response: " + error.message + ".",
            sticky: false,
            position: "top-center",
            type: "error"
          });
        } else if (error.code == 5) {
          // Image too large.
          $().toastmessage("showToast", {
            text: "Error, image file too large: " + error.message + ".",
            sticky: false,
            position: "top-center",
            type: "error"
          });
        } else if (error.code == 6) {
          // Invalid image type.
          $().toastmessage("showToast", {
            text: "Error, invalid image type: " + error.message + ".",
            sticky: false,
            position: "top-center",
            type: "error"
          });
        } else if (error.code == 7) {
          // Image can be uploaded only to same domain in IE 8 and IE 9.
          $().toastmessage("showToast", {
            text: "Error, cannot upload to a different domain in your browser: " + error.message + ".",
            sticky: false,
            position: "top-center",
            type: "error"
          });
        }
      }
    });