var oraConsole = {};
oraConsole.init = function () {
    // Save the original error method
    oraConsole.error = console.error;
    // Redefine console.error method with a custom function
    console.error = function (message) {
        apex.server.plugin(
            oraConsole.apexPluginId,
            {
                x01: 'Error',
                x02: message,
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
        // Call the original console.log function.
        oraConsole.error.apply(console, arguments);
    };
};