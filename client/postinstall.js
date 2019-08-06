var fs        = require('fs');
var path      = require('path');
var exec_sync = require("child_process").execSync

var filename  = __filename;
var patch_dir = path.resolve('patches');
var node_dir  = path.resolve('node_modules');

function print_new_line()     { console.log(''); }
function print_msg(msg)       { console.log('\x1b[36m%s\x1b[0m', msg); }
function print_msg_bold(msg)  { console.log('\x1b[36m\x1b[1m%s\x1b[0m', msg); }
function error_message(msg)   { console.log('\x1b[31m\x1b[1m%s\x1b[0m', msg); }
function warning_message(msg) { console.log('\x1b[33m%s\x1b[0m', msg); }

function print_start() {
  print_new_line();
  print_msg_bold(">> Start NPM 'postinstall' script: " + filename);
  print_new_line();
}

function print_done() {
  print_new_line();
  print_msg_bold("<< Done NPM 'postinstall' script: " + filename);
  print_new_line();
}

function fs_error_message(msg, err) {
  print_new_line();
  error_message('[ERROR] ' + msg + '.');
  print_new_line();
  console.log(err);
  print_new_line();
}

function patch_file(pkg, file) {
  var src   = path.resolve('patches', pkg, file);
  var dest  = path.resolve('node_modules', pkg, file)
  var patch = pkg + '/' + file
  print_msg('  - ' + patch);
  print_msg('      source     : ' + src);
  print_msg('      destination: ' + dest);
  if (!fs.existsSync(src)) {
    warning_message("  [WARNING] Patch source file does not exist: " + src);
    return;
  }
  if (!fs.existsSync(dest)) {
    warning_message("  [WARNING] Patch destination file does not exist: " + dest);
    return;
  }
  try {
    var content = fs.readFileSync(src, 'utf-8');
    fs.writeFileSync(dest, content, 'utf-8')
  } catch (err) {
    fs_error_message("Cannot patch file: " + patch, err);
  }
}

function patch_files() {
  if (!fs.existsSync(patch_dir)) { return; }
  var pkgs = fs.readdirSync(patch_dir);
  if (!Array.isArray(pkgs)) { return; }
  print_new_line();
  print_msg('Patch files:');
  pkgs.forEach(function(pkg) {
    var files = fs.readdirSync(path.resolve('patches', pkg));
    if (Array.isArray(files)) {
      files.forEach(function(file){
        patch_file(pkg, file)
      })
    }
  })
  print_new_line();
}

function delete_file(file) {
  if (!fs.existsSync(file)) { return; }
  print_new_line();
  print_msg('Deleting file: ' + file);
  exec_sync('rm ' + '"' + file + '"');
}

function bower_install() {
  var cmd = 'bower install'
  print_msg('Running: ' + cmd);
  exec_sync(cmd)
  print_new_line();
}

function ember_generate(pkg) {
  var cmd = 'ember g ' + pkg
  print_new_line();
  print_msg('Running: ' + cmd);
  exec_sync(cmd)
}

//
// Main
//
print_start();

bower_install();

patch_files(); // run before ember_generate otherwise ember will error

ember_generate('ember-colpick');

delete_file(path.resolve('bower_components', 'pickadate', 'lib', 'translations', 'fa_ir.js'));

print_done();
