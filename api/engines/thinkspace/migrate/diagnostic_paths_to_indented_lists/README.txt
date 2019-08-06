= Convert Diagnostic Path Phases to Indented List Phases

== thinkspace_indented_list_lists
    integer  authable_id      #=> from path authable
    string   authable_type
    integer  listable_id      #=> keep??? (was to allow a path to reference the list)
    string   listable_type
    string   title            #=> from path title

== thinkspace_indented_list_responses
    integer  user_id          #=> from path_item
    integer  list_id          #=> list created
    integer  ownerable_id     #=> from path_item
    string   ownerable_type
    json     value            #=> generated from nested path_items ordered by 'position'
                              #=> [:items] array of item hashes:
                                    pos_y:               y,              #=> running position of nested path_items
                                    pos_x:               x,              #=> number of path_item parents
                                    itemable_id:         itemable_id,    #=> from path_item.path_itemable
                                    itemable_type:       itemable_type,
                                    itemable_value_path: 'value',        #=> hard-code for observations

                                    + description:                       #=> from path_item.description
                                    + category:                          #=> from path_item.category (json column)

== Build indented list from path items

   * filter by:
     * spaces
     * assignments
     * phases
     * paths

   * for each phase

     * get each 'path' phase_component
       * get path (componentable)
       * create list
       * for each path's unique path_item ownerables
          * build response.value.items hash from path_items
          * create response for list
       * update phase_component to the list
       * repeat

       - validation checks:
         - all of a ownerable's path items have same user_id
         - path.authable exists
         - the path_itemable exists

       - item hash:
          {
            root_path_item: [recursive path items in position order]
            root_path_item: [same]
            ...
          }

   * questions:
     * delete the path and path_items after converted?

== Phase Schema

    phase -> *phase_template  #=> change to indented_list template
          -> team_category    #=> as-is

    phase -> phase_components
              -> *componentable     #=> create indentd_list record and set as componentable
              -> *common_component  #=> change to indented_list component
              -  *section           #=> get from phase_template.template 'section' or 'title' (or hard code if only one template)

== Diagnostic Path Schema

    path
      -  authable (phase)
      ?  title

    path -> path_items
            - user_id
            - ownerable
            - path_itemable
            - description
            - category



== Indented List Schema

   list
     - authable (phase)
     - listable (???)

   list -> response

   response
     - user_id
     - ownerable
     - value[:items]


== Schemas

=== thinkspace_casespace_phases
    integer  assignment_id
    integer  phase_template_id
    integer  team_category_id
    string   title
    text     description
    string   state

=== thinkspace_casespace_phase_templates
    string   title
    string   name
    string   description
    boolean  domain,      default: false
    text     template

=== thinkspace_casespace_phase_components
    integer  component_id
    integer  phase_id
    integer  componentable_id
    string   componentable_type
    string   section

=== thinkspace_casespace_phase_scores
    integer  user_id
    integer  phase_state_id
    decimal  score,          precision: 9, scale: 3

=== thinkspace_casespace_phase_states
    integer  user_id
    integer  phase_id
    integer  ownerable_id
    string   ownerable_type
    string   current_state



=== thinkspace_diagnostic_path_paths
    integer  authable_id
    string   authable_type
    string   title

=== thinkspace_diagnostic_path_path_items
    integer  user_id
  x integer  path_id
    integer  ownerable_id
    string   ownerable_type
  x integer  parent_id
    integer  path_itemable_id
    string   path_itemable_type
  x integer  position
    text     description
    json     category

=== thinkspace_diagnostic_path_viewer_viewers
    integer  user_id
    integer  path_id
    integer  authable_id
    string   authable_type
    integer  ownerable_id
    string   ownerable_type


