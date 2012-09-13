var editor = ace.edit("editor");

editor.getSession().setUseWrapMode(true);
editor.setShowPrintMargin(false);

var MarkdownMode = require("ace/mode/markdown").Mode;
editor.getSession().setMode(new MarkdownMode());

editor.setTheme("ace/theme/twilight");