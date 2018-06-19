/* CodeMirror stuffs */
var editor = CodeMirror(document.getElementById('editor'), {
    lineNumbers: true,
    lineWrapping: true,
    styleActiveLine: true,
    mode: "pandoc",
    theme: "solarized light",
    keyMap: "vim",
    autofocus: true,
    cursorScrollMargin: 50,
    indentUnit: 4,
    // autoCloseBrackets: true, // messes with \(\) and \[\]
    value: "% title\n% author\n\n\\newcommand{\\set}[1]{\\left\\{\\, #1 \\,\\right\\}}\n\\newcommand{\\abs}[1]{\\left\\lvert #1 \\right\\rvert}\n\n",
});
var commandDisplay = document.getElementById('command-display');
var keys = '';
editor.on('vim-keypress', function(key) {
    keys = keys + key;
    commandDisplay.innerHTML = keys;
});
editor.on('vim-command-done', function(e) {
    keys = '';
    window.setTimeout(function () {
        commandDisplay.innerHTML = keys;
    }, 500);
    /* replicating vim behaviour */
});
editor.on("changes", refresh_right);

/* VIM mode hoohah */
var current_mode = "normal";
editor.on("vim-mode-change", function (e) {
    current_mode = e.mode;
    // TODO: update statusline
});
editor.setOption("extraKeys", { // expandtabs
    Tab: function(cm){
        if (current_mode == "insert") {
            cm.execCommand('insertSoftTab');
        }
    }
});

/*
 * TODO:
 * status line => on 'vim-mode-change' etc
 * import/upload => doc.setValue()
 * download     | these are easy
 * copy HTML    |
 */
