// @flow
import * as type from './actionTypes';
import { Map } from 'immutable';

export const INITIAL_STATE = Map({
  timelines: [],
  pid: null,
  msg: 0,
  pidPrefix: ''
});

const reducer = (state: any = INITIAL_STATE, action: any) => {
  if (action.type === type.UPDATE_TIMELINES) {
    const [{ timelines }] = action.payload;
    return state.set(
      'timelines',
      timelines.map(t => ({ ...t, timeline: t.timeline.reverse() }))
    );
  }

  if (action.type === type.SET_CURRENT_PID) {
    const [pid] = action.payload;
    return state.set('pid', pid).set('msg', 0);
  }

  if (action.type === type.SET_CURRENT_MSG) {
    const [msg] = action.payload;
    return state.set('msg', msg);
  }

  if (action.type === type.SET_INIT) {
    const [{ pid }] = action.payload;
    return state.set('pidPrefix', pid.replace(/<|>/, '').split('.')[0]);
  }

  if (action.type === 'PUSH_TIMELINE_PID') {
    const pid = action.pid;
    return state.update('timelines', timelines =>
      [
        {
          pid,
          timeline: []
        }
      ].concat(timelines)
    );
  }

  if (action.type === type.REMOVE_PID) {
    const [pid] = action.payload;
    return state.update('timelines', timelines =>
      timelines.filter(t => t.pid !== pid)
    );
  }

  if (action.type === '@@router/LOCATION_CHANGE') {
    const { pathname } = action.payload;
    const pid = pathname.replace(/\/timeline(\/?)/, '');
    return state.set('pid', pid).set('msg', 0);
  }

  return state;
};

export default reducer;
