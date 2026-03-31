import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.join(__dirname, '..');

const enc = encodeURIComponent;
const read = (f) => fs.readFileSync(path.join(root, f), 'utf8');

const data = {
  ombre: 'data:image/svg+xml;charset=utf-8,' + enc(read('img/products/ombre.svg')),
  slate: 'data:image/svg+xml;charset=utf-8,' + enc(read('img/products/slate.svg')),
  beard: 'data:image/svg+xml;charset=utf-8,' + enc(read('img/products/beard-oil.svg')),
  grey: 'data:image/svg+xml;charset=utf-8,' + enc(read('img/products/grey-code.svg')),
  f1: 'data:image/svg+xml;charset=utf-8,' + enc(read('img/footer-mosaic-1.svg')),
  f2: 'data:image/svg+xml;charset=utf-8,' + enc(read('img/footer-mosaic-2.svg')),
  f3: 'data:image/svg+xml;charset=utf-8,' + enc(read('img/footer-mosaic-3.svg')),
};

let html = read('index.html');

html = html.replace(
  /src="\/daniil-portfolio\/apollo-premium\/img\/products\/ombre\.svg"/,
  'src="' + data.ombre + '"'
);
html = html.replace(
  /src="\/daniil-portfolio\/apollo-premium\/img\/products\/slate\.svg"/,
  'src="' + data.slate + '"'
);
html = html.replace(
  /src="\/daniil-portfolio\/apollo-premium\/img\/products\/beard-oil\.svg"/,
  'src="' + data.beard + '"'
);
html = html.replace(
  /src="\/daniil-portfolio\/apollo-premium\/img\/products\/grey-code\.svg"/,
  'src="' + data.grey + '"'
);
html = html.replace(
  /src="\/daniil-portfolio\/apollo-premium\/img\/footer-mosaic-1\.svg"/,
  'src="' + data.f1 + '"'
);
html = html.replace(
  /src="\/daniil-portfolio\/apollo-premium\/img\/footer-mosaic-2\.svg"/,
  'src="' + data.f2 + '"'
);
html = html.replace(
  /src="\/daniil-portfolio\/apollo-premium\/img\/footer-mosaic-3\.svg"/,
  'src="' + data.f3 + '"'
);

html = html.replace(
  /<link rel="stylesheet" href="\/daniil-portfolio\/apollo-premium\/styles\.css[^"]*"\s*\/>/,
  '<link rel="stylesheet" href="./styles.css?v=data-uri-imgs" />'
);
html = html.replace(
  /<script src="\/daniil-portfolio\/apollo-premium\/app\.js"/,
  '<script src="./app.js"'
);

html = html.replace(/\n\s*data-local="[^"]*"/g, '');

fs.writeFileSync(path.join(root, 'index.html'), html, 'utf8');
console.log('OK: inlined 7 SVG data-URIs, relative css/js, stripped data-local');
