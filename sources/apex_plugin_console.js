var oraConsole = {};
oraConsole.init = function () {
    // Define generic log function with level parameter for later use
    oraConsole.log = function (level, message, scope, stack) {
        apex.server.plugin(
            oraConsole.apexPluginId,
            {
                x01: level,
                x02: message,
                x03: 'APEX JS: ' + scope,
                x04: stack,
                x05: navigator.userAgent,
                p_debug: $v('pdebug')
            },
            {
                success: function (dataString) {
                    if (dataString != 'SUCCESS') {
                        oraConsole.error('Oracle Instrumentation Console: AJAX call had server side PL/SQL error: ' + dataString + '.');
                    }
                },
                error: function (xhr, status, errorThrown) {
                    oraConsole.error('Oracle Instrumentation Console: AJAX call terminated with errors: ' + errorThrown + '.');
                },
                dataType: 'text'
            }
        );
        // Call the original console.xxx function.
        if (level === 1) {
            oraConsole.original.error.apply(console, arguments);
        } else if (level === 2 && oraConsole.level >= 2/*Warning*/) {
            oraConsole.original.warn.apply(console, arguments);
        } else if (level === 3 && oraConsole.level >= 3/*Info*/) {
            oraConsole.original.info.apply(console, arguments);
        } else if (level === 4 && oraConsole.level >= 4/*Verbose*/) {
            oraConsole.original.debug.apply(console, arguments);
        }
    };

    oraConsole.original = {};
    // Save the original error method
    oraConsole.original.error = console.error;
    // Redefine console.error method with a custom function
    console.error = function (message) { oraConsole.log(1, message) };
    // Do the same with other console methods depending on our current debug level
    if (oraConsole.level >= 2/*Warning*/) {
        oraConsole.original.warn = console.warn;
        console.warn = function (message) { oraConsole.log(2, message) };
    }
    if (oraConsole.level >= 3/*Info*/) {
        oraConsole.original.info = console.info;
        console.info = function (message) { oraConsole.log(3, message) };
        oraConsole.original.log = console.log;
        console.log = function (message) { oraConsole.log(3, message) };
    }
    if (oraConsole.level >= 4/*Verbose*/) {
        oraConsole.original.debug = console.debug;
        console.debug = function (message) { oraConsole.log(4, message) };
    }
};

/*
FIXME: Should we have an extended error handling when log level is higher than
1(error) as described and the end of [this
article](https://programming.vip/docs/javascript-global-error-handling.html)?

- https://developer.mozilla.org/en-US/docs/Web/API/GlobalEventHandlers/onerror
- https://dzone.com/articles/capture-and-report-javascript-errors-with-windowon
- https://programming.vip/docs/javascript-global-error-handling.html
*/
window.onerror = function (msg, url, lineNo, columnNo, error) {
    var string = msg.toLowerCase();
    var substring = "script error";
    if (string.indexOf(substring) > -1) {
        oraConsole.log(
            1,
            'Script error in external file (different origin): See browser console for details'
        );
    } else {
        oraConsole.log(
            1,
            msg,
            'url ' + url.match(/\/\/.*?(\/.*)/)[1] + ', line ' + lineNo + ', column ' + columnNo,
            error.stack
        );
    }
    return false;
};
