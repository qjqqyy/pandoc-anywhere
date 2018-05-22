/*
 * debounce: from https://davidwalsh.name/javascript-debounce-function
 */
function debounce(func, wait, immediate) {
    var timeout;
    return function() {
        var context = this, args = arguments;
        var later = function() {
            timeout = null;
            if (!immediate) func.apply(context, args);
        };
        var callNow = immediate && !timeout;
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
        if (callNow) func.apply(context, args);
    };
};

var updateHeight = debounce(function() {
    this.style.height = 'auto';
    this.style.height = (this.scrollHeight+2) + 'px';
}, 100);

var tx = document.getElementById('markdown_textarea');
tx.addEventListener("input", updateHeight);
tx.addEventListener("cut", updateHeight);
tx.addEventListener("paste", updateHeight);
window.addEventListener("resize", function () {
    updateHeight.call(document.getElementById('markdown_textarea'));
});
updateHeight.call(document.getElementById('markdown_textarea'));

var refresh_right = debounce(function() {
    var xhr = new XMLHttpRequest();
    xhr.open("POST", '/api.pl', true);
    xhr.setRequestHeader("Content-type", "text/plain; charset=utf-8");
    // TODO: loading animations???
    xhr.onreadystatechange = function() {
        if(xhr.readyState == XMLHttpRequest.DONE && xhr.status == 200) {
            //console.log(xhr.responseText);
            response = xhr.responseText;
            right = document.getElementById("pandoc_output");
            right.innerHTML = response;
            MathJax.Hub.Queue(["Typeset", MathJax.Hub, right]);
        }
    }
    xhr.send(tx.value);
}, 1000);       // <-- debounce timeout

tx.addEventListener("input", refresh_right);
tx.addEventListener("cut", refresh_right);
tx.addEventListener("paste", refresh_right);
// vim: et sw=4
