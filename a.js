const readline = require('readline');

/**
 * 
 * @param {string} input 
 * @returns 
 */
function processText(input,gou) {
    return input.split('\n\n').map((section,index) => {
        section = section.replace(/<br\/?>/gi, '\n').replace(/<\/p>/gi, '\n').replace(/<[^>]+>/g, '')
        const sex =  section.split('\n').map(e => e.trim());
        return `(${index + 1}) ` + sex.shift() + '\n##\n' + sex.join('\n').trim() + '\n##\n' + gou
    }).join('\n###\n');
}

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
    terminal: false
});

let input = '';

rl.on('line', function(line) {
    input += line + '\n';
});

rl.on('close', function() {
    const output = processText(input.trim(), '#号');
    console.log(output);
});

//pbpaste | node a.js | sed 's/#号/#2号/g' | pbcopy