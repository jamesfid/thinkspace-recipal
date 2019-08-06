import { Selector } from 'testcafe'

export const select = {
  space: Selector('ul.space-list.primary-list li'),
  case:  Selector('ul.assignment-list.primary-list li'),
  phase: Selector('div.casespace-assignment_phase-list .casespace-assignment_phase-title'),
}

export const first = {
  space: select.space.nth(0),
  case:  select.case.nth(0),
  phase: select.phase.nth(0),
}

export const last = {
  space: select.space.nth(-1),
  case:  select.case.nth(-1),
  phase: select.phase.nth(-1),
}
