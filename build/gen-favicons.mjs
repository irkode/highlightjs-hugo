// generated with https://claude.ai/chat/
import favicons from 'favicons';
import fs from 'fs/promises';
import path from 'path';

const src = 'hugen/docs/themes/huggingface/assets/img/huggingface-1254x1254.png'; // Icon base image
const outputDir = 'hugen/docs/themes/huggingface/assets/img/favicons';

const config = {
  path: '/favicons',
  appName: 'Highlight 4 Hugo',
  background: '#ffffff',
  theme_color: '#ffffff',
  icons: {
    android: true,        // 192x192 + 512x512
    appleIcon: true,      // apple-touch-icon (180x180)
    appleStartup: false,  // ~20 splash screens - skip for normal websites
    favicons: true,       // favicon.ico + favicon-16x16, 32x32, 48x48
    windows: false,       // MS Tiles - barely relevant anymore
    yandex: false         // Yandex - negligible market share outside Russia
  }
};

const response = await favicons(src, config);

await fs.mkdir(outputDir, { recursive: true });

// Generate images
await Promise.all(
  response.images.map(img =>
    fs.writeFile(path.join(outputDir, img.name), img.contents)
  )
);

// Generate supplemental files (manifest etc.)
await Promise.all(
  response.files.map(file =>
    fs.writeFile(path.join(outputDir, file.name), file.contents)
  )
);

console.log(`\nDone! Files in: ${outputDir}`);

// Print generated tags to console for comparison with your hardcoded set.
// Your target set (SVG and WebP managed separately):
//
//   <link rel="icon" href="/favicons/favicon.ico">
//   <link rel="icon" type="image/png" sizes="16x16" href="/favicons/favicon-16x16.png">
//   <link rel="icon" type="image/png" sizes="32x32" href="/favicons/favicon-32x32.png">
//   <link rel="icon" type="image/png" sizes="48x48" href="/favicons/favicon-48x48.png">
//   <link rel="icon" type="image/png" sizes="192x192" href="/favicons/android-chrome-192x192.png">
//   <link rel="apple-touch-icon" sizes="180x180" href="/favicons/apple-touch-icon-180x180.png">
//   <link rel="icon" type="image/svg+xml" href="/favicons/favicon.svg">
//   <link rel="icon" type="image/webp" sizes="32x32" href="/favicons/favicon-32x32.webp">
//   <link rel="icon" type="image/webp" sizes="192x192" href="/favicons/android-chrome-192x192.webp">

console.log('\n=== Generated HTML tags (compare with your hardcoded set) ===\n');
response.html.forEach(tag => console.log(tag));
