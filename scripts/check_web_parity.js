'use strict';
const fs = require('node:fs');
const vm = require('node:vm');
const assert = require('node:assert/strict');

const read = (path) => fs.readFileSync(path, 'utf8');
const web = read('index.html');
const shell = read('lib/main.dart');
const guest = read('lib/mewvio_demo_profile_page.dart');
const account = read('lib/account/account_page.dart');
const home = read('lib/social_home_page.dart');
const notice = '© 2026 MEWVIO Technologies. All rights reserved.';

for (const [label, content] of [
  ['Web', web], ['Guest Android profile', guest], ['Signed-in Android profile', account],
]) {
  assert(content.includes(notice), label + ' must show the shared copyright');
}
for (const name of ['Home', 'Videos', 'Chat', 'Profile']) {
  assert(shell.includes("'"+name+"'"), 'Android tab missing: '+name);
  assert(web.includes("'"+name+"'"), 'Web tab missing: '+name);
}
assert(shell.includes("Key('nav-Create')"), 'Android center create tab missing');
assert(web.includes('class="create-center"'), 'Web center create tab missing');
assert(web.includes('data-action="create-menu"'), 'Web create entrypoint missing');
assert(home.includes('mewvio-cat.svg'), 'Android official branding missing');
assert(web.includes('const CAT_LOGO='), 'Web official branding missing');
assert(web.includes('mew-profile-logo'), 'Web app-style profile missing');
assert(web.includes('mew-profile-tabs'), 'Web app-style profile tabs missing');
assert(!web.includes('MEWVIO Wallet'), 'Removed wallet must not reappear on web');
const scripts = web.match(/<script>([\s\S]*?)<\/script>/g) || [];
assert(scripts.length, 'No embedded web app script');
const inline = scripts[scripts.length - 1].replace(/^<script>/, '').replace(/<\/script>$/, '');
new vm.Script(inline, {filename:'MEWVIO/index.html'});
console.log('MEWVIO App + Web parity and browser JS syntax checks passed.');
