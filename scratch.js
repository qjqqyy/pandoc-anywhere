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

var numsec = document.getElementById('cb_numbersections');

/* XXX: consider switching to standalone with an iframe */
var refresh_right = debounce(function() {
    var xhr = new XMLHttpRequest();

    xhr.open("POST", '/api.pl' + (numsec.checked ? '?numbersections' : '' ), true);
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
    xhr.send(editor.getValue());
}, 1000);       // <-- debounce timeout

/* refresh when checkbox toggled too */
numsec.addEventListener("click", refresh_right);

/* add a toggle for orientation */
var smallwrap = document.getElementById('smallwrap');
smallwrap.style.flexDirection = 'row-reverse';  /* I always change this so... */
function toggle_orientation() {
    smallwrap.style.flexDirection = smallwrap.style.flexDirection == 'row' ?  'row-reverse' : 'row';
}
