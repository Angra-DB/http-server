-module(adb_web_app). 

% The purpose of an active application is 
% to run one or more processes. In order to 
% have some control over those process, they 
% showld be spawned and managed by supervisors: 
% processes that implements the supervisor 
% behavior. 

-behavior(application). 

-export([start/2, stop/1, kickoff/1]).

-define(DEFAULT_WEB_PORT, 4321). 
-define(DEFAULT_CORE_PORT, 1234).

% this operation is called when the 
% OTP system wants to start our application. 
% actually, this is the most relevant 
% operation of this model, which is responsible 
% for starting the root supervisor. 

kickoff(web) ->
	application:start(adb_web);
kickoff(all) ->
	lager:start(),
	application:start(adb_web);
kickoff(_) ->
	invalid_argument.

start(_Type, _StartArgs) ->

    lager:info("starting the AngraDB Web server ~n"), 
        
    WPort = ?DEFAULT_WEB_PORT, 
    CPort = ?DEFAULT_CORE_PORT, 
    
    
    lager:info("listening to HTTP requests on port ~w ~n", [WPort]),
    lager:info("listening to TCP  requests on port ~w ~n", [CPort]),
    
    {ok, LSock} = gen_tcp:listen(1234, [{active,true}]),
 
    case adb_web_master_sup:start_link([LSock, WPort]) of 
	{ok, Pid} -> adb_web_sup:start_child(), 
                     adb_sup:start_child(), 
                     {ok, Pid};
	Other -> {error, Other}
    end. 
        
    %% case adb_web_sup:start_link(Port) of 
    %% 	{ok, Pid} -> adb_web_sup:start_child(),
    %% 		      {ok, Pid};	 
    %% 	Other -> error_logger:error_msg(" error: ~s", [Other]), 
    %% 		 {error, Other}
    %%  end. 

stop(_State) ->
    ok. 
