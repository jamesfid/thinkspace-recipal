export default {

  'thinkspace/casespace':  path: '/casespace'

  '/casespace':
    'thinkspace/casespace/assignments':         path: '/cases', resource: true
    'thinkspace/casespace/phases':              path: '/cases/:assignment_id/phases', resource: true

  '/casespace/cases':
    show:                                       path: '/:assignment_id'
    scores:                                     path: '/:assignment_id/scores'
    'thinkspace/casespace/assignments/reports': path: '/:assignment_id/reports', resource: true

  '/casespace/cases/:assignment_id/reports':
    show: path: '/:token'

  '/casespace/cases/:assignment_id/phases':
    show: path: '/:phase_id'

}