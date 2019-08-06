var fs        = require('fs');
var path      = require('path');
var exec_sync = require("child_process").execSync

var filename  = __filename;
var pkg_dir   = path.resolve('packages');
var node_dir  = path.resolve('node_modules');
var bower_dir = path.resolve('bower_components');

function print_new_line()     { console.log(''); }
function print_msg(msg)       { console.log('\x1b[36m%s\x1b[0m', msg); }
function print_msg_bold(msg)  { console.log('\x1b[36m\x1b[1m%s\x1b[0m', msg); }
function error_message(msg)   { console.log('\x1b[31m\x1b[1m%s\x1b[0m', msg); }
function warning_message(msg) { console.log('\x1b[33m%s\x1b[0m', msg); }

function print_start() {
  print_new_line();
  print_msg_bold(">> Start NPM 'preinstall' script: " + filename);
  print_new_line();
}

function print_done() {
  print_new_line();
  print_msg_bold("<< Done NPM 'preinstall' script: " + filename);
  print_new_line();
}

function print_directories() {
  print_msg('Directories:');
  print_msg('  packages        : ' + pkg_dir);
  print_msg('  node_modules    : ' + node_dir);
  print_msg('  bower_components: ' + bower_dir);
  print_new_line();
}

function fs_error_message(msg, err) {
  print_new_line();
  error_message('[ERROR] ' + msg + '.');
  print_new_line();
  console.log(err);
  print_new_line();
}

function delete_directory(dir) {
  if (!fs.existsSync(dir)) { return; }
  print_msg('Deleting directory: ' + dir);
  exec_sync('rm -rf ' + '"' + dir + '"'); // throws error and stops script if cannot delete
}

function make_directory(dir) {
  if (fs.existsSync(dir)) { return; }
  print_msg("Make directory: " + dir);
  try {
    fs.mkdirSync(dir);
  } catch (err) {
    fs_error_message("Cannot make directory: " + dir, err);
  }
}

function symlink_packages() {
  var pkgs = fs.readdirSync(pkg_dir);
  if (!Array.isArray(pkgs)) { return; }
  print_msg("Symlink Packages:");
  var from, to;
  pkgs.forEach(function(file) {
    from = path.resolve('packages', file);
    to   = path.resolve('node_modules', file);
    try {
      print_msg('  - ' + path.basename(file));
      print_msg("      from: " + from);
      print_msg("      to  : " + to);
      fs.symlinkSync(from, to);
    } catch (err) {
      fs_error_message("Cannot create symlink for: " + file, err);
    }
  });
}

//
// Main
//
print_start();
print_directories();

if (!fs.existsSync(pkg_dir)) {
  error_message('Package directory does not exist: ' + pkg_dir);
  return;
}

delete_directory(node_dir);
delete_directory(bower_dir);

make_directory(node_dir);
symlink_packages();

print_done();
