import Util              from '../../helpers/util'
import { first }         from '../../helpers/selectors';
import { login, logout } from '../../helpers/roles'

fixture `navigation test`

test('nav-to space-case-phase', async t => {
  const filename = Util.basename(__filename)
  const user     = Util.get_user()

  Util.print.cyanb(` ${filename}: ${user}`)

  await login(user)

  await t
    .click(first.space)
    .click(first.case)
    .click(first.phase)

  if (Util.is_debug()) {await t.debug()}

  await logout(t)
})
