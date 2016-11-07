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

get({http_request, 'GET', {_, Path}, _}, _Head, _UserData)->
    Tokens = string:tokens(binary:bin_to_list(Path), "/"),
	processRequest({get, Tokens}).

post({http_request, 'POST', {_, Path}, _}, _Head, Body, UserData) ->
    Tokens = string:tokens(binary:bin_to_list(Path), "/"),
    Payload = string:join([[C] || C <- binary:bin_to_list(Body)], ""),
	processRequest({post, lists:append(Tokens, Payload)}). 

put(_, _, _, _) ->
 gen_web_server:http_reply(404).

delete(_, _, _) ->
 gen_web_server:http_reply(404).

    
processRequest({get, ["db", DBName, Id]}) -> 
 case gen_tcp:connect({127,0,0,1}, 1234, [binary, {active, false}]) of
 	{ok, Socket} -> gen_tcp:send(Socket, "lookup " ++ Id),
 					case gen_tcp:recv(Socket, 0, 500) of
 						{ok,Packet} 	-> 	gen_web_server:http_reply(200, Packet);				
 						{error, Reason} -> 	io:format("~p", [Reason]),
 											gen_web_server:http_reply(500, "Internal server error")
 					end,
 					gen_web_server:http_reply(200, "ok");				
 	_ -> gen_web_server:http_reply(500, "Internal server error")
 end;

processRequest({get, _}) -> "It works";
   
processRequest ({post, ["db", DBName, "doc", Body]}) ->
 case gen_tcp:connect({127,0,0,1}, 1234, [binary, {active, false}]) of
 	{ok, Socket} -> gen_tcp:send (Socket, "save " ++ Body),
 	                case gen_tcp:recv(Socket, 0, 500) of
 	                	{ok, Packet}      -> gen_web_server:http_reply(200, Packet);
 	                	{error, Reason}   -> io:format ("~p", [Reason]),
 	                						 gen_web_server:http_reply(500, "Internal server error")
 	                end,
 	                gen_web_server:http_reply(200, "ok");
  _ -> gen_web_server:http_reply(500, "Internal server error")
 end;
 	           
processRequest ({post, A}) -> gen_web_server:http_reply(400, "Bad request"), 
  io:format("~p ~n", [A]). 
    
