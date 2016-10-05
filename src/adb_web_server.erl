-module(adb_web_server).

-behaviour(gen_web_server).

-export([start_link/1, start_link/2]).

-export([init/1, get/3, delete/3, put/4, post/4]).

start_link(Port) ->
    gen_web_server:start_link(?MODULE, Port, []).


start_link(IP, Port) ->
    gen_web_server:start_link(?MODULE, IP, Port, []).

init([]) ->
    {ok, []}.

get({http_request, 'GET', {_, _}, _}, _Head, _UserData)->
    gen_web_server:http_reply(200, "Hello World").

post(_, _, _, _) ->
 gen_web_server:http_reply(404).

put(_, _, _, _) ->
 gen_web_server:http_reply(404).

delete(_, _, _) ->
 gen_web_server:http_reply(404).

    

    