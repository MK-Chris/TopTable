/**
 *  Handle form fields
 *
 *
 */
$(document).ready(function(){
  /*
    Replace <textarea>s with CKEditor instances.
  */
  $("textarea").ckeditor({
    toolbarGroups: [
    	{ name: 'document', groups: [ 'mode', 'document', 'doctools' ] },
    	{ name: 'clipboard', groups: [ 'clipboard', 'undo' ] },
    	{ name: 'editing', groups: [ 'find', 'selection', 'editing' ] },
    	{ name: 'basicstyles', groups: [ 'basicstyles', 'cleanup' ] },
    	'/',
    	{ name: 'paragraph', groups: [ 'list', 'indent', 'blocks', 'align', 'bidi', 'paragraph' ] },
    	{ name: 'links', groups: [ 'links' ] },
    	{ name: 'insert', groups: [ 'insert' ] },
    	'/',
    	{ name: 'styles', groups: [ 'styles' ] },
    	{ name: 'colors', groups: [ 'colors' ] },
    	{ name: 'tools', groups: [ 'tools' ] },
    	{ name: 'others', groups: [ 'others' ] },
    	{ name: 'about', groups: [ 'about' ] }
    ],
    removeButtons: 'Form,Checkbox,Radio,TextField,Textarea,Select,Button,ImageButton,HiddenField,spellchecker,Save,NewPage,Maximize',
    extraPlugins: 'lineutils,widget,oembed,enterkey',
    enterMode: CKEDITOR.ENTER_BR
  });
});