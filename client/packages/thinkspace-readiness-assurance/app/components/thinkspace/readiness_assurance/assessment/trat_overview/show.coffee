import ember            from 'ember'
import ns               from 'totem/ns'
import ajax             from 'totem/ajax'
import response_manager from 'thinkspace-readiness-assurance/response_manager'
import m_data_rows      from 'thinkspace-readiness-assurance/mixins/data_rows'
import base             from 'thinkspace-readiness-assurance/base/ra_component'

export default base.extend m_data_rows,

  team_data_rows:  null
  columns_per_row: 5

  willInsertElement: -> @setup()

  setup: ->
    @ra.load_messages()
    @store = @totem_scope.get_store()
    @get_trat_overview().then (payload) =>
      @set_team_data(payload)

  set_team_data: (payload) ->
    teams     = payload.teams
    questions = payload.questions
    data      = payload.data
    results   = []
    for q in questions
      qid      = q.id
      question = q.question
      choices  = q.choices
      answers  = []
      for hash in teams
        team      = hash.team
        title     = team.title
        tdata     = @get_team_data(data, team.id)
        answer_id = tdata and tdata.answers[qid]
        answer    = @get_team_answer(choices, answer_id)
        answers.push {title, answer}
      results.push({question, answers})
    @set 'team_data_rows', @get_data_rows(results)

  get_team_data: (data, id) -> data.findBy 'team_id', id

  get_team_answer: (choices, id) ->
    choice = id and choices.findBy('id', id)
    choice = choice.label if choice
    choice or 'none'

  get_trat_overview: ->
    new ember.RSVP.Promise (resolve, reject) =>
      model  = ns.to_p 'ra:assessment'
      action = 'trat_overview'
      verb   = 'post'
      query  = {model, action, verb}
      @totem_scope.add_auth_to_ajax_query(query)
      ajax.object(query).then (payload) =>
        resolve(payload)
