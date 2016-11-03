-module(adb_web).

-export([start/0]).

start() -> 
	start(lager),
	start(adb_web).

start(App) ->
	start_ok(App, application:start(App)).
	
start_ok(_App, ok) ->
	ok;
start_ok(_App, {error, {already_started, _App}}) ->
	ok;
start_ok(App, {error, {not_started, Dep}}) ->
    ok = start(Dep),
    start(App);
start_ok(App, {error, Reason}) ->
	erlang:error({app_start_failed, App, Reason}).