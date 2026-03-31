/**
 * Пересобирает data: URI в index.html из актуальных файлов img/*.svg
 * (после правок иллюстраций запуск: node scripts/rebuild-data-uris.mjs из папки apollo-premium)
 */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.join(__dirname, '..');
const enc = encodeURIComponent;

const order = [
  'img/products/ombre.svg',
  'img/products/slate.svg',
  'img/products/beard-oil.svg',
  'img/products/grey-code.svg',
  'img/footer-mosaic-1.svg',
  'img/footer-mosaic-2.svg',
  'img/footer-mosaic-3.svg',
];

let html = fs.readFileSync(path.join(root, 'index.html'), 'utf8');
let i = 0;
html = html.replace(/src="data:image\/svg\+xml;charset=utf-8,[^"]*"/g, () => {
  if (i >= order.length) throw new Error('More data-URI src in HTML than SVG files');
  const uri = 'data:image/svg+xml;charset=utf-8,' + enc(fs.readFileSync(path.join(root, order[i++]), 'utf8'));
  return 'src="' + uri + '"';
});
if (i !== order.length) throw new Error('Expected ' + order.length + ' data-URI src, found ' + i);

html = html.replace(/\.\/styles\.css\?v=[^"]*/, './styles.css?v=rich-product-svgs');

fs.writeFileSync(path.join(root, 'index.html'), html, 'utf8');
console.log('OK: rebuilt', order.length, 'inline SVG data-URIs');
