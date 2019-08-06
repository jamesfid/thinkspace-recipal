import path from 'path'

const print_line = function(color, msg) { console.log('\x1b[' + color + 'm%s\x1b[0m', msg) }
const print_bold = function(color, msg) { console.log('\x1b[' + color + 'm\x1b[1m%s\x1b[0m', msg) }

const populate_users = function(users) {
  if (users.length > 0) {return}
  let env_users = process.env['tc_user'] || 'read_1'
  for (let user of env_users.split(',')) { users.push(user) }
}

export default {

  basename: function(filename) { return path.basename(filename) },

  is_debug: function() { return process.env['tc_debug'] == 'true' },

  print: {
    log:        function(msg) { console.log(msg) },
    red:        function(msg) { print_line('31', msg) },
    redb:       function(msg) { print_bold('31', msg) },
    on_red:     function(msg) { print_line('41', msg) },
    green:      function(msg) { print_line('32', msg) },
    greenb:     function(msg) { print_bold('32', msg) },
    on_green:   function(msg) { print_line('42', msg) },
    yellow:     function(msg) { print_line('33', msg) },
    yellowb:    function(msg) { print_bold('33', msg) },
    on_yellow:  function(msg) { print_line('43', msg) },
    magenta:    function(msg) { print_line('35', msg) },
    magentab:   function(msg) { print_bold('35', msg) },
    on_magenta: function(msg) { print_bold('45', msg) },
    cyan:       function(msg) { print_line('36', msg) },
    cyanb:      function(msg) { print_bold('36', msg) },
    on_cyan:    function(msg) { print_bold('46', msg) },
    white:      function(msg) { print_line('97', msg) },
  },

  capitalize(str) { return str && str[0].toUpperCase() + str.slice(1); },

  users: [],

  get_user() {
    populate_users(this.users)
    return this.users.shift()
  },

  async select_nth(selector, {nuser, random}={}) {
    let count = await selector.count;
    if (random === true) { return Math.floor(Math.random() * count); }
    let nth = 0;
    if (nuser && nuser <= count) {nth = nuser - 1;}
    return nth;
  },

}
