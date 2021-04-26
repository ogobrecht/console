const fs   = require('fs')
const glob = require('glob');
const toc  = require('markdown-toc');
const navRegex = /<!-- *nav *-->[\s\S]*?<!-- *navstop *-->/gi;
const renderNavigation = function (type) {
    var menu = '';
    const entries = [
        {top:true, name:"Index",           file:"README.md"},
        {top:true, name:"Installation",    file:"installation.md"},
        {top:true, name:"Getting Started", file:"getting-started.md"},
        {top:true, name:"API Overview",    file:"api-overview.md"},
        {top:true, name:"Package Console", file:"package-console.md"},
        {top:true, name:"Changelog",       file:"changelog.md"},
        {top:true, name:"Uninstallation",  file:"uninstallation.md"},
    ];
    entries.forEach(function (entry) {
        if (type === 'top' && entry.top){
            menu += '| [' + entry.name + '](' + entry.file + ')\n';
        }
        else if (type === 'index' && entry.file !== 'README.md') {
            menu += '- [' + entry.name + '](' + entry.file + ')\n';
        }
    });
    if (type === 'top') {
        menu = menu.substr(2); //delete first pipe character and space
    }
    return '<!-- nav -->\n\n' + menu + '\n<!-- navstop -->';
};

console.log('BUILD DOCS NAVIGATION');
glob('docs/*.md', function (err, files) {
    if (err) throw err;
    files.forEach(function (file) {
        var content = fs.readFileSync(file, 'utf8');
        console.log('- process file ' + file);
        if (file === 'docs/README.md') {
            content = content.replace(navRegex, renderNavigation('index'));
        }
        else {
            if (file === 'docs/package-console.md') {
                content = '<!-- nav --><!-- navstop -->' + content;
            }
            content = content.replace(navRegex, renderNavigation('top'));
            content = toc.insert(content, {maxdepth: 2, bullets: '-'});
        }
        fs.writeFileSync(file, content);
    });
});


