export default {

  '/casespace':
    'thinkspace/casespace/case_manager': path: '/case_manager', resource: true

  '/casespace/case_manager':
    'thinkspace/casespace/case_manager/spaces':      path: '/spaces', resource: true
    'thinkspace/casespace/case_manager/assignments': path: '/cases', resource: true
    'thinkspace/casespace/case_manager/phases':      path: '/phases', resource: true

  '/casespace/case_manager/spaces':
    new:     path: '/new'
    edit:    path: '/:space_id/edit'
    clone:   path: '/:space_id/clone'
    roster:  path: '/:space_id/roster'
    grades:  path: '/:space_id/grades'
    'thinkspace/casespace/case_manager/team_sets': path: '/:space_id/team_sets', resource: true

  '/casespace/case_manager/cases':
    new:         path: '/new'
    edit:        path: '/:assignment_id/edit'
    clone:       path: '/:assignment_id/clone'
    delete:      path: '/:assignment_id/delete'
    phase_order: path: '/:assignment_id/phase_order'
    'thinkspace/casespace/case_manager/assignments/peer_assessment': path: '/:assignment_id/peer_assessment', resource: true

  '/casespace/case_manager/cases/:assignment_id/peer_assessment':
    assessments: path: '/assessments'

  '/casespace/case_manager/phases':
    edit: path: '/:phase_id/edit'

  '/casespace/case_manager/spaces/:space_id/team_sets':
    new:  path: '/new'
    show: path: '/:team_set_id'
    edit: path: '/:team_set_id/edit'
    'thinkspace/casespace/case_manager/teams': path: '/:team_set_id/teams', resource: true

  '/casespace/case_manager/spaces/:space_id/team_sets/:team_set_id/teams':
    new:  path: '/new'
    show: path: '/:team_id'
    edit: path: '/:team_id/edit'

}
