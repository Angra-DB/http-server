-module(adb_web_sup).

% As explained before (see the adb_app.erl module), 
% an active OTP application consists of one or more 
% process that do the work (that is, they receive 
% server side requests and manipulate our database). 
% These processes are started indirectly by supervisors, 
% which are responsible for supervising them and restarting 
% them if necessary (OTP in Action). A running application is 
% a tree of processes, both supervisors and workers. 

-behavior(supervisor). 

%% API
-export([start_link/1, start_child/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

start_link(Port) ->
    supervisor:start_link({local, ?SERVER}, ?MODULE,[Port]).

start_child() ->
    supervisor:start_child(?SERVER, []).

init([Port]) ->
    Server = {adb_web_server, {adb_web_server, start_link, [Port]}, % {Id, Start, Restart, ... }  
	      permanent, brutal_kill, worker,[adb_web_server]},    
    Children = [Server], 
    RestartStrategy = {one_for_one, 0, 1},  % {How, Max, Within} ... Max restarts within a period
    {ok, {RestartStrategy, Children}}. 
 
