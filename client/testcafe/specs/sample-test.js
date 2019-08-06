import Util from '../helpers/util'

fixture `sample test`

test('hello world', async t => {
  const filename = Util.basename(__filename)
  Util.print.cyanb(`  ${filename} says: Hello World!`)
})
