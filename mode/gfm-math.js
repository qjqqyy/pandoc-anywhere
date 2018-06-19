/*
 * defines gfm + inline math mode
 * modified from multiplex-test.js
 */
(function() {
  CodeMirror.defineMode("gfm-math", function(config, parserConfig){
    var outer = CodeMirror.getMode(config, {
        name: "gfm",
        allowAtxHeaderWithoutSpace: true,
        gitHubSpice: false,
        taskLists: false,
        xml: false,
    });

    var args = [outer];
    var delims = ['()', '[]']       /* tex_math_single_backslash */
    for (var i = 0; i < delims.length; i++) {
        args.push({
            open: "\\" + delims[i][0],
            close: "\\" + delims[i][1],
            mode: CodeMirror.getMode({}, "tex-mathmode"),
            delimStyle: 'delim',
            innerStyle: 'math',
        });
    }
    /* supported environments */
    var environs = ['align', 'gather', 'equation']; // cbf add others
    for (var i = 0; i < environs.length; i++) {
        args.push(
            {
                open: "\\begin{" + environs[i] + "}",
                close: "\\end{" + environs[i] + "}",
                mode: CodeMirror.getMode({}, "tex-mathmode"),
                delimStyle: 'delim',
                innerStyle: 'math',
            },
            {
                open: "\\begin{" + environs[i] + "*}",
                close: "\\end{" + environs[i] + "*}",
                mode: CodeMirror.getMode({}, "tex-mathmode"),
                delimStyle: 'delim',
                innerStyle: 'math',
            }
        );
    }
    return CodeMirror.multiplexingMode.apply(this, args);
  });
})();
