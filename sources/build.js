const fs = require('fs');
const toChunks = function (str, size) {
    const numChunks = Math.ceil(str.length / size)
    const chunks = new Array(numChunks)
    for (let i = 0, o = 0; i < numChunks; ++i, o += size) {
        chunks[i] = str.substr(o, size)
    }
    return chunks
};
const toApexLoadFile = function (filePath) {
    const hexString = Buffer.from(fs.readFileSync(filePath, 'utf8')).toString('hex')
    const chunks = toChunks(hexString, 200)
    let apexLoadFile = '';
    for (let i = 0; i < chunks.length; ++i) {
        apexLoadFile += "wwv_flow_api.g_varchar2_table(" + (i+1) + ") := '" + chunks[i] + "';\n"
    }
    return apexLoadFile
};

console.log('ORACLE INSTRUMENTATION CONSOLE: BUILD INSTALL SCRIPTS');
console.log('- build file install/create_console_objects.sql');
fs.writeFileSync(
    'install/create_console_objects.sql',
    '--DO NOT CHANGE THIS FILE - IT IS GENERATED WITH THE BUILD SCRIPT sources/build.js\n' +
    fs.readFileSync('sources/install_template.sql', 'utf8')
        .replace('@set_ccflags.sql', function () { return fs.readFileSync('sources/set_ccflags.sql', 'utf8') })
        .replace('@CONSOLE_LOGS.sql', function () { return fs.readFileSync('sources/CONSOLE_LOGS.sql', 'utf8') })
        .replace('@CONSOLE_SESSIONS.sql', function () { return fs.readFileSync('sources/CONSOLE_SESSIONS.sql', 'utf8') })
        .replace('@CONSOLE.pks', function () { return fs.readFileSync('sources/CONSOLE.pks', 'utf8') })
        .replace('@CONSOLE.pkb', function () { return fs.readFileSync('sources/CONSOLE.pkb', 'utf8') })
        .replace('@show_errors.sql', function () { return fs.readFileSync('sources/show_errors.sql', 'utf8') })
        .replace('@log_installed_version.sql', function () { return fs.readFileSync('sources/log_installed_version.sql', 'utf8') })
    /*
    Without the anonymous function call to fs.readFileSync we get wrong results, if
    we have a dollar signs in our package body text - the last answer explains it:
    https://stackoverflow.com/questions/9423722/string-replace-weird-behavior-when-using-dollar-sign-as-replacement
    */
);

console.log('- build file install/apex_plugin.sql');
// increase file version in template
fs.writeFileSync(
    'sources/apex_plugin_template.sql',
    fs.readFileSync('sources/apex_plugin_template.sql', 'utf8')
        .replace(/p_files_version=>(\d+)/, function(match, $1) { return 'p_files_version=>' + (parseInt($1)+1) })
);
// read template and build plug-in
fs.writeFileSync(
    'install/apex_plugin.sql',
    '--DO NOT CHANGE THIS FILE - IT IS GENERATED WITH THE BUILD SCRIPT sources/build.js\n' +
    fs.readFileSync('sources/apex_plugin_template.sql', 'utf8')
        .replace('#CONSOLE.JS#', toApexLoadFile('sources/apex_plugin_console.js'))
        .replace('#VERSION#', 'testus')
);
