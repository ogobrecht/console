const fs = require('fs');
const crypto = require('crypto');
const UglifyJS = require("uglify-js");
const toMd5Hash = function (string) {
    return crypto.createHash('md5').update(string).digest("hex")
};
const toChunks = function (str, size) {
    const numChunks = Math.ceil(str.length / size)
    const chunks = new Array(numChunks)
    for (let i = 0, o = 0; i < numChunks; ++i, o += size) {
        chunks[i] = str.substr(o, size)
    }
    return chunks
};
const toApexPluginFile = function (code) {
    const hexString = new Buffer.from(code).toString('hex') // eslint-disable-line no-undef
    const chunks = toChunks(hexString, 200)
    let apexLoadFile = '';
    for (let i = 0; i < chunks.length; ++i) {
        apexLoadFile += "  wwv_flow_api.g_varchar2_table(" + (i + 1) + ") := '" + chunks[i] + "';\n"
    }
    return apexLoadFile
};

console.log('ORACLE INSTRUMENTATION CONSOLE: BUILD INSTALL SCRIPTS');
console.log('- build file install/create_console_objects.sql');
fs.writeFileSync('install/create_console_objects.sql',
    '--DO NOT CHANGE THIS FILE - IT IS GENERATED WITH THE BUILD SCRIPT sources/build.js\n' +
    fs.readFileSync('sources/install_template.sql', 'utf8')
        .replace('@set_ccflags.sql', function () { return fs.readFileSync('sources/set_ccflags.sql', 'utf8') })
        .replace('@CONSOLE_LOGS.sql', function () { return fs.readFileSync('sources/CONSOLE_LOGS.sql', 'utf8') })
        .replace('@CONSOLE_SESSIONS.sql', function () { return fs.readFileSync('sources/CONSOLE_SESSIONS.sql', 'utf8') })
        .replace('@CONSOLE.pks', function () { return fs.readFileSync('sources/CONSOLE.pks', 'utf8') })
        .replace('@CONSOLE.pkb', function () { return fs.readFileSync('sources/CONSOLE.pkb', 'utf8') })
        .replace('@create_clean_up_job.sql', function () { return fs.readFileSync('sources/create_clean_up_job.sql', 'utf8') })
        .replace('@show_errors.sql', function () { return fs.readFileSync('sources/show_errors.sql', 'utf8') })
        .replace('@log_installed_version.sql', function () { return fs.readFileSync('sources/log_installed_version.sql', 'utf8') })
    /*
    Without the anonymous function call to fs.readFileSync we get wrong results, if
    we have a dollar signs in our package body text - the last answer explains it:
    https://stackoverflow.com/questions/9423722/string-replace-weird-behavior-when-using-dollar-sign-as-replacement
    */
);

console.log('- build file install/apex_plugin.sql');
let consoleJsCode = fs.readFileSync('sources/apex_plugin_console.js', 'utf8');
let version = fs.readFileSync('sources/CONSOLE.pks', 'utf8').match(/c_version\s+constant.*?'(.*?)'/)[1];
let md5Hash = toMd5Hash(consoleJsCode);
let conf = JSON.parse(fs.readFileSync('apexplugin.json', 'utf8'));
let minified;
if (conf.version !== version || conf.jsFile.md5Hash !== md5Hash) {
    // minify JS code
    minified = UglifyJS.minify({ "console.js": consoleJsCode }, { sourceMap: true });
    if (minified.error) throw minified.error;
    // build plug-in
    conf.version = version;
    conf.jsFile.md5Hash = md5Hash;
    conf.jsFile.version += 1;
    fs.writeFileSync('install/apex_plugin.sql',
        '--DO NOT CHANGE THIS FILE - IT IS GENERATED WITH THE BUILD SCRIPT sources/build.js\n\n' +
        fs.readFileSync('sources/apex_plugin_template.sql', 'utf8')
            .replace('#CONSOLE_VERSION#', conf.version)
            .replace('#FILE_VERSION#', conf.jsFile.version)
            .replace('#CONSOLE_JS_FILE#', toApexPluginFile(fs.readFileSync('sources/apex_plugin_console.js', 'utf8')))
            .replace('#CONSOLE_JS_FILE_MIN#', toApexPluginFile(minified.code))
            .replace('#CONSOLE_JS_FILE_MIN_MAP#', toApexPluginFile(minified.map))
    );
    fs.writeFileSync('apexplugin.json', JSON.stringify(conf, null, 2));
}
