var oraConsole = {};
oraConsole.init = function () {
    // Define generic log function with level parameter for later use
    oraConsole.log = function (level, message, scope, stack) {
        apex.server.plugin(
            oraConsole.apexPluginId,
            {
                x01: level,
                x02: message,
                x03: scope,
                x04: stack,
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
        switch (level) {
            case 'Error':
                oraConsole.error.apply(console, arguments);
                break;
            case 'Warning':
                oraConsole.warn.apply(console, arguments);
                break;
            case 'Info':
                oraConsole.info.apply(console, arguments);
                break;
            case 'Verbose':
                oraConsole.debug.apply(console, arguments);
                break;
        }

    };

    // Save the original error method
    oraConsole.error = console.error;
    // Redefine console.error method with a custom function
    console.error = function (message) { oraConsole.log('Error', message) };
};


//https://developer.mozilla.org/en-US/docs/Web/API/GlobalEventHandlers/onerror
/*
window.onerror = function (msg, url, lineNo, columnNo, error) {
  var string = msg.toLowerCase();
  var substring = "script error";
  if (string.indexOf(substring) > -1){
    alert('Script Error: See Browser Console for Detail');
  } else {
    var message = [
      'Message: ' + msg,
      'URL: ' + url,
      'Line: ' + lineNo,
      'Column: ' + columnNo,
      'Error object: ' + JSON.stringify(error)
    ].join(' - ');

    alert(message);
  }

  return false;
};
*/