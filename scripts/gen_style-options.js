/* 
  generate javascript to inject all available stylesheets to developer.html
  this uses the build/styles folder which includes styles from extra
  generated with kind help from https://duckduckgo.com/?q=DuckDuckGo+AI+Chat&ia=chat&duckai=1
**/
const fs = require('fs');
const path = require('path');

const cssDirectory = path.join(__dirname, '../highlight.js/build/styles');
const outputFilePath = path.join(__dirname, '../work/style-options.js');

function getCssFiles(dir) {
  let results = [];
  const list = fs.readdirSync(dir);

  list.forEach(file => {
    const filePath = path.join(dir, file);
    const stat = fs.statSync(filePath);

    if (stat && stat.isDirectory()) {
      results = results.concat(getCssFiles(filePath)); // Recurse into subdirectory
    } else if (file.endsWith('.css') && !file.endsWith('.min.css')) {
      // Store the path relative to the cssDirectory
      const relativePath = path.relative(cssDirectory, filePath).replace(/\\/g, '/'); // Normalize path for web
      results.push(relativePath);
    }
  });

  return results;
}

const stylesheets = "'" + getCssFiles(cssDirectory).join("','") + "'";

const outputContent = `
    const cssOptions = [${stylesheets}];
    const selectElement = document.querySelector('.theme');
    selectElement.innerHTML = '';
    cssOptions.forEach(css => {
      const opt = document.createElement('option');
      opt.textContent = css;
      selectElement.appendChild(opt);
    });
`;

fs.writeFile(outputFilePath, outputContent, (err) => {
  if (err) {
    return console.error('Error writing file: ' + err);
  }
});
