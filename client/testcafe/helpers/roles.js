import { t, Role, Selector } from 'testcafe'

export const user_password = 'password'

export const login_url = 'http://localhost:4200'

export const select = {
  login: {
    email:    Selector('input').withAttribute('type', 'email'),
    password: Selector('input').withAttribute('type', 'password'),
    submit:   Selector('button').withAttribute('type', 'submit'),
  },
  logout: {
    user_info: Selector('.navbar_user-info'),
    sign_out:  Selector('#user-expansion').find('a').withText('Sign Out'),
  },
  navbar: Selector('#navbar'),
}

export async function login(username, password=user_password) {
  let role = Role(login_url, async t => { await login_user(`${username}@sixthedge.com`, password) }, {preserveUrl: true})
  await t.useRole(role)
}

export async function logout(tt) {
  await tt
    .click(select.logout.user_info)
    .click(select.logout.sign_out)
}

const login_user = async function (email, password=user_password) {
  await t
    .typeText(select.login.email, email)
    .typeText(select.login.password, password)
    .click(select.login.submit)
  // Long timeout incase first login to allow creation of api serializers.
  await t.expect(select.navbar.exists).ok('login failure', {timeout: 25000})
}
