%%% Copyright (c) 2017, erlang.pl
%%%-------------------------------------------------------------------
%%% @doc
%%% Tracking all timeline observers
%%% @end
%%%-------------------------------------------------------------------
-module(epl_timeline).
-behaviour(gen_server).

%% API
-export([start_link/0,
         subscribe/0,
         unsubscribe/0,
         add_timeline/1]).

%% gen_server callbacks
-export([init/1,
         handle_call/3,
         handle_cast/2,
         handle_info/2,
         terminate/2,
         code_change/3]).

-record(state, {subscribers = [], timelines = []}).

%%%===================================================================
%%% API functions
%%%===================================================================

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

subscribe() ->
    gen_server:cast(?MODULE, {subscribe, self()}).

unsubscribe() ->
    gen_server:cast(?MODULE, {unsubscribe, self()}).

add_timeline(Pid) ->
    get_server:cast(?MODULE, {add_timeline, Pid}).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================
init([]) ->
    ok = epl:subscribe(),
    {ok, #state{}}.

handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.

handle_cast({subscribe, Pid}, State = #state{subscribers = Subs}) ->
    {noreply, State#state{subscribers = [Pid|Subs]}};
handle_cast({unsubscribe, Pid}, State = #state{subscribers = Subs}) ->
    {noreply, State#state{subscribers = lists:delete(Pid, Subs)}};
handle_cast({add_timeline, Pid}, State = #state{timelines = Timelines}) ->
    {ok, Timeline} = epl_timeline_observer:start_link(list_to_pid(Pid)),
    {noreply, State#state{timelines = [Timeline|Timelines]}};
handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info({data, _, _}, State = #state{subscribers = Subs, timelines = Timelines}) ->
    States = lists:map(fun(TS) -> epl_timeline_observer:timeline(TS) end, Timelines),
    JSON = epl_json:encode(#{states => States}, <<"timeline-info">>),
    [Pid ! {data, JSON} || Pid <- Subs],
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.