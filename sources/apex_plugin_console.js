/* global apex:false */
var oic = {}; // Namespace for "Oracle Instrumentation Console".
oic.oc  = {}; // Namespace for "Original Console" methods.
oic.oa  = {}; // Namespace for "Original Apex.debug" methods.
oic.ln  = {}; // Namespace for "Level Names".
oic.ln.error = 1;
oic.ln.warning = 2;
oic.ln.info = 3;
oic.ln.verbose = 4;
oic.toString = function (argumentsArray) {
    var result = "";
    for (var i = 0; i < argumentsArray.length; i++) {
        result += (i !== 0 ? ' ' : '');
        if (typeof argumentsArray[i] === 'object') {
            result += '\n' + JSON.stringify(argumentsArray[i], null, 2);
        }
        else {
            result += argumentsArray[i];
        }
    }
    return result;
}
oic.init = function () {
    // Define generic log function with level parameter for later use
    oic.message = function (level, message, scope, stack) {
        apex.server.plugin(
            oic.pluginId,
            {
                x01: level,
                x02: message,
                x03: 'APEX JS: ' + scope,
                x04: stack,
                x05: navigator.userAgent,
                p_debug: false
            },
            {
                success: function (dataString) {
                    if (dataString != 'SUCCESS') {
                        oic.error('Oracle Instrumentation Console: AJAX call had server side PL/SQL error: ' + dataString + '.');
                    }
                },
                error: function (xhr, status, errorThrown) {
                    oic.error('Oracle Instrumentation Console: AJAX call terminated with errors: ' + errorThrown + '.');
                },
                dataType: 'text'
            }
        );
    };

    // Redefine console.error and apex.debug.error methods with a custom function
    oic.oc.error = console.error;
    console.error = function () {
        oic.message(oic.ln.error, oic.toString(arguments), 'console.error');
        oic.oc.error.apply(console, arguments);
    };
    oic.oa.error = apex.debug.error;
    apex.debug.error = function () {
        oic.message(oic.ln.error, oic.toString(arguments), 'apex.debug.error');
        // Because apex.debug.error does more than simply log to the console we
        // use here the original one. In all other cases we simply redirect to
        // the appropriate console methods to save overhead of additional
        // function invocations.
        oic.oa.error.apply(apex.debug, arguments);
    };

    /* Currently we capture only errors because of the heavy overhead when do an AJAX call for every log event
    // Do the same with other console methods depending on our current debug level
    if (oic.level >= oic.ln.warning) {
        oic.oc.warn = console.warn;
        console.warn = function () {
            oic.message(oic.ln.warn, oic.toString(arguments), 'console.warn');
            oic.oc.warn.apply(console, arguments);
        };
    }
    if (oic.level >= oic.ln.info) {
        oic.oc.info = console.info;
        console.info = function () {
            oic.message(oic.ln.info, oic.toString(arguments), 'console.info');
            oic.oc.info.apply(console, arguments);
        };
        oic.oc.log = console.log;
        console.log = function () {
            oic.message(oic.ln.info, oic.toString(arguments), 'console.log');
            oic.oc.log.apply(console, arguments);
        };
        oic.oc.trace = console.trace;
        console.trace = function () {
            oic.message(oic.ln.info, oic.toString(arguments), 'console.trace');
            oic.oc.trace.apply(console, arguments);
        };
    }
    if (oic.level >= oic.ln.verbose) {
        oic.oc.debug = console.debug;
        console.debug = function () {
            oic.message(oic.ln.verbose, oic.toString(arguments), 'console.debug');
            oic.oc.debug.apply(console, arguments);
        };
    }
    */

    /* Currently we capture only errors because of the heavy overhead when do an AJAX call for every log event
    // Do the same with other apex methods depending on our current debug level
    if (oic.level >= oic.ln.warning && apex.debug.getLevel() >= apex.debug.LOG_LEVEL.WARN) {
        oic.oa.warn = apex.debug.warn;
        apex.debug.warn = function () {
            oic.message(oic.ln.warn, oic.toString(arguments), 'apex.debug.warn');
            oic.oc.warn.apply(console, arguments); // Using oic.oc is by intention.
        };
    }
    if (oic.level >= oic.ln.info && apex.debug.getLevel() >= apex.debug.LOG_LEVEL.INFO) {
        oic.oa.info = apex.debug.info;
        apex.debug.info = function () {
            oic.message(oic.ln.info, oic.toString(arguments), 'apex.debug.info');
            oic.oc.info.apply(console, arguments); // Using oic.oc is by intention.
        };
        // If we overwrite the apex.debug.log method, we run into an endless
        // loop when APEX debug mode is switched on. Reason: APEX is logging
        // every AJAX call with apex.debug.log. FIXME: find a workaround for
        // this.
        //oic.oa.log = apex.debug.log;
        //apex.debug.log = function () {
        //    oic.message(oic.ln.info, oic.toString(arguments), 'apex.debug.log');
        //    oic.oc.log.apply(console, arguments); // Using oic.oc is by intention.
        //};
    }
    if (oic.level >= oic.ln.verbose && apex.debug.getLevel() >= apex.debug.LOG_LEVEL.APP_TRACE) {
        oic.oa.trace = apex.debug.trace;
        apex.debug.trace = function () {
            oic.message(oic.ln.verbose, oic.toString(arguments), 'apex.debug.trace');
            oic.oc.debug.apply(console, arguments); // Using oic.oc is by intention.
        };
    }
    */

    // FIXME: Should we have an extended error handling when log level is higher
    // than 1(error) as described and the end of [this
    // article](https://programming.vip/docs/javascript-global-error-handling.html)?
    //
    // - https://developer.mozilla.org/en-US/docs/Web/API/GlobalEventHandlers/onerror
    // - https://dzone.com/articles/capture-and-report-javascript-errors-with-windowon
    // - https://programming.vip/docs/javascript-global-error-handling.html
    window.onerror = function (msg, url, lineNo, columnNo, error) {
        // Use only the relative url path to shorten the scope:
        var scope = 'window.onerror, url ' + url.match(/\/\/.*?(\/.*)/)[1] + ', line ' + lineNo + ', column ' + columnNo;
        if (msg.toLowerCase().indexOf('script error') > -1) {
            oic.message(
                oic.ln.error,
                'Script error in an external file (different origin): See browser console for details',
                scope
            );
        } else {
            oic.message(
                oic.ln.error,
                msg,
                scope,
                error.stack
            );
        }
        return false;
    };
};

