-module(adb_web_master_sup).
-behaviour(supervisor).

-export([start_link/1, init/1]).

-export([stop/0]).

start_link([LSock, WPort]) ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, [LSock, WPort]).

init([LSock, WPort]) ->
    ChildSpecList = [child(adb_sup, LSock), child(adb_web_sup, WPort)],
    {ok, {{rest_for_one, 2, 3600}, ChildSpecList}}.


child(Module, Arg) ->
    {Module, {Module, start_link, [Arg]}, permanent, 2000, supervisor, [Module]}.

stop() ->
    exit(whereis(?MODULE), shutdown).
