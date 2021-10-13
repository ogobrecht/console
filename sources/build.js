const fs = require('fs');
const UglifyJS = require('uglify-js');
const crypto = require('crypto');
const toMd5Hash = function (string) { return crypto.createHash('md5').update(string).digest('hex') };
let consoleJsCode, minified, version, md5Hash, conf;

const toChunks = function (text, size) {
    const numChunks = Math.ceil(text.length / size);
    const chunks = new Array(numChunks);
    for (let i = 0, start = 0; i < numChunks; ++i, start += size) {
        chunks[i] = text.substr(start, size);
    }
    return chunks;
};

const toApexPluginFile = function (text) {
    const hexString = new Buffer.from(text).toString('hex'); // eslint-disable-line no-undef
    const chunks = toChunks(hexString, 200);
    let apexLoadFile = 'begin\n' +
        '  wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;\n';
    for (let i = 0; i < chunks.length; ++i) {
        apexLoadFile += `  wwv_flow_api.g_varchar2_table(${(i + 1)}) := '${chunks[i]}';\n`;
    }
    apexLoadFile += 'end;\n/';
    return apexLoadFile;
};

console.log('ORACLE INSTRUMENTATION CONSOLE: BUILD INSTALL SCRIPTS');
console.log('- build file install/create_console_objects.sql');
fs.writeFileSync('install/create_console_objects.sql',
    '--DO NOT CHANGE THIS FILE - IT IS GENERATED WITH THE BUILD SCRIPT sources/build.js\n' +
    fs.readFileSync('sources/install_template.sql', 'utf8')
        .replace('@set_ccflags.sql', function () { return fs.readFileSync('sources/set_ccflags.sql', 'utf8') })
        .replace('@CONSOLE_CONF.sql', function () { return fs.readFileSync('sources/CONSOLE_CONF.sql', 'utf8') })
        .replace('@CONSOLE_LOGS.sql', function () { return fs.readFileSync('sources/CONSOLE_LOGS.sql', 'utf8') })
        .replace('@CONSOLE.pks', function () { return fs.readFileSync('sources/CONSOLE.pks', 'utf8') })
        .replace('@CONSOLE.pkb', function () { return fs.readFileSync('sources/CONSOLE.pkb', 'utf8') })
        .replace('@create_purge_job.sql', function () { return fs.readFileSync('sources/create_purge_job.sql', 'utf8') })
        .replace('@show_errors.sql', function () { return fs.readFileSync('sources/show_errors.sql', 'utf8') })
        .replace('@log_installed_version.sql', function () { return fs.readFileSync('sources/log_installed_version.sql', 'utf8') })
    /*
    Without the anonymous function call to fs.readFileSync we get wrong results, if
    we have a dollar signs in our package body text - the last answer explains it:
    https://stackoverflow.com/questions/9423722/string-replace-weird-behavior-when-using-dollar-sign-as-replacement
    */
);

console.log('- build file install/apex_plugin.sql');
consoleJsCode = fs.readFileSync('sources/apex_plugin_console.js', 'utf8');
version = fs.readFileSync('sources/CONSOLE.pks', 'utf8').match(/c_version\s+constant.*?'(.*?)'/)[1];
md5Hash = toMd5Hash(consoleJsCode);
conf = JSON.parse(fs.readFileSync('apexplugin.json', 'utf8'));
if (conf.version !== version || conf.jsFile.md5Hash !== md5Hash) {
    minified = UglifyJS.minify({ "console.js": consoleJsCode }, { sourceMap: true });
    if (minified.error) throw minified.error;
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

console.log('- change version number in README.md');
fs.writeFileSync('README.md',
    fs.readFileSync('README.md', 'utf8')
        .replace(/version(.*). Feedback/, 'version ' + conf.version + '. Feedback')
);
