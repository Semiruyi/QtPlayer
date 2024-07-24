

function resurl(s) { //why called twice if in qrc?
    return resprefix + s
}

String.prototype.startsWith = function(s) {
    return this.indexOf(s) === 0;
};

String.prototype.endsWith = function(suffix) {
    return this.indexOf(suffix, this.length - suffix.length) !== -1;
};

function fileName(path) {
    return path.substring(path.lastIndexOf("/") + 1)
}

function msec2string(t) {
    t = Math.floor(t/1000)
    var ss = t%60
    t = (t-ss)/60
    var mm = t%60
    var hh = (t-mm)/60
    if (ss < 10)
        ss = "0" + ss
    if (mm < 10)
        mm = "0" + mm
    if (hh < 10)
        hh = "0" + hh
    return hh + ":" + mm +":" + ss
}


function htmlEscaped(s) {
    if (!s) {
        return '';
    }
    var escaped = '';
    var namedHtml = {
        '38': '&amp;',
        '60': '&lt;',
        '62': '&gt;',
        '34': '&quot;',
        '160': '&nbsp;',
        '162': '&cent;',
        '163': '&pound;',
        '164': '&curren;',
        '169': '&copy;',
        '174': '&reg;',
    };
    var wasNewLine = 0;
    for (var i = 0, il = s.length; i < il; ++i) {
        var c = s.charCodeAt(i);
        var es = namedHtml[c];
        if (typeof es !== 'undefined') {
            wasNewLine = 0;
            escaped += es;
        } else {
            if (c === 13 || c === 10) {
                if (wasNewLine == 0)
                    escaped += '<br>';
                wasNewLine++;
            } else {
                wasNewLine = 0;
                escaped += String.fromCharCode(c);
            }
        }
    }
    return escaped;
}


function formattedVideoDuration(duration) {

    var seconds = Math.floor(duration / 1000)

    var hours = Math.floor(seconds / 3600)

    var minutes = Math.floor((seconds % 3600) / 60)

    var remainingSeconds = seconds % 60

    var formattedHours = hours < 10 ? '0' + hours : hours
    var formattedMinutes = minutes < 10 ? '0' + minutes : minutes
    var formattedSeconds = remainingSeconds < 10 ? '0' + remainingSeconds : remainingSeconds

    if(hours === 0) {
        return formattedMinutes + ':' + formattedSeconds
    }
    return formattedHours + ':' + formattedMinutes + ':' + formattedSeconds
}

function rgb(r,g,b){
    var ret=(r << 16 | g << 8 | b);
    return("#"+ret.toString(16)).toUpperCase();
}
