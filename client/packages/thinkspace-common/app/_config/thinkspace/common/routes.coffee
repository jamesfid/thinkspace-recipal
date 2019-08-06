export default {

  root_url:                   path: '/'
  users:                      path: '/users'
  'thinkspace/common/spaces': path: '/spaces'
  'users/password':           path: '/users/password'

  '/users':
    sign_in: path: '/sign_in'
    sign_up: path: '/sign_up'
    terms:   path: '/:user_id/terms'
    show:    path: '/:user_id'

  '/users/:user_id':
    profile: path: '/profile'
    keys:    path: '/keys'
    terms:   path: '/terms'

  '/users/password':
    new:          path: '/reset'
    show:         path: '/reset/:token'
    fail:         path: '/reset/fails'
    success:      path: '/reset/success'
    confirmation: path: '/reset/confirmation'

  '/spaces':
    show: path: '/:space_id'
    scores: path: '/:space_id/scores'

}
