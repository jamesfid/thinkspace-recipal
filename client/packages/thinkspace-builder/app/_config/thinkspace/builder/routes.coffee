export default {

  'thinkspace/builder': path: '/builder', resource: true

  # ### Case editing
  '/builder':
    'thinkspace/builder/cases': path: '/cases', resource: true
    'thinkspace/builder/phases': path: '/phases', resource: true

  '/builder/cases':
    new:       path: '/:space_id/new'
    details:   path: '/:case_id/details'
    templates: path: '/:case_id/templates'
    phases:    path: '/:case_id/phases'
    logistics: path: '/:case_id/logistics'
    overview:  path: '/:case_id/overview'

  '/builder/phases':
    edit: path: '/:phase_id/edit'

}
