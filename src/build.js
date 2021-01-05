var fs = require('fs');
console.log('building install file 2_install_console.sql');
fs.writeFileSync(
    '2_install_console.sql',
    '--DO NOT CHANGE THIS FILE - IT IS GENERATED WITH THE BUILD SCRIPT src/build.js\n' +
    fs.readFileSync('src/install.sql', 'utf8')
        .replace('@console_logs.sql', function(){return fs.readFileSync('src/console_logs.sql', 'utf8')})
        .replace('@CONSOLE.pks', function(){return fs.readFileSync('src/CONSOLE.pks', 'utf8')})
        .replace('@CONSOLE.pkb', function(){return fs.readFileSync('src/CONSOLE.pkb', 'utf8')})
        // Read what this function thing is doing, without it we get wrong results.
        // If we have a dollar signs in our package body text - the last answer explains:
        // https://stackoverflow.com/questions/9423722/string-replace-weird-behavior-when-using-dollar-sign-as-replacement
);
