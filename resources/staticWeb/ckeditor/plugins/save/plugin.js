/*
 Copyright (c) 2003-2018, CKSource - Frederico Knabben. All rights reserved.

 For licensing, see LICENSE.md or https://ckeditor.com/legal/ckeditor-oss-license

*/
(function(){var b={readOnly:1,modes:{wysiwyg:1,source:1},exec:function(a){if(a.fire("save")&&(a=a.element.$.form))try{a.submit()}catch(b){a.submit.click&&a.submit.click()}}};CKEDITOR.plugins.add("save",{lang:"de,en",icons:"save",hidpi:!0,init:function(a){a.elementMode==CKEDITOR.ELEMENT_MODE_REPLACE&&(a.addCommand("save",b).startDisabled=!a.element.$.form,a.ui.addButton&&a.ui.addButton("Save",{label:a.lang.save.toolbar,command:"save",toolbar:"document,10"}))}})})();