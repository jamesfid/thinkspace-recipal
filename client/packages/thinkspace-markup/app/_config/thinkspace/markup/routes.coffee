export default {
  'thinkspace/markup': path: '/markup'

  '/markup':
    'thinkspace/markup/libraries': path: '/libraries', resource :true

  '/markup/libraries':
    edit: path: '/:library_id/edit'
}