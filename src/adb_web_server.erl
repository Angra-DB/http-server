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

post({http_request, 'POST', {_, Path}, _}, _Head, Body, _UserData) ->
    Tokens = string:tokens(binary:bin_to_list(Path), "/"),
    Payload = string:join([[C] || C <- binary:bin_to_list(Body)], ""),
    printElements(lists:append(Tokens, Payload)),
    processRequest({post, lists:append(Tokens, Payload)}). 

put(_, _, _, _) ->
 gen_web_server:http_reply(404).

delete({http_request, 'DELETE', {_, Path}, _}, _Head, _UserData)->
    Tokens = string:tokens(binary:bin_to_list(Path), "/"),
    processRequest({delete, Tokens}).

connect() ->
     case gen_tcp:connect({127,0,0,1}, 1234, [binary, {active, false}]) of
	 {ok, Socket} -> Socket;			 
       _ -> throw(could_not_connect_to_the_server)
   end.

sendCommand(Socket, Command) ->
    gen_tcp:send(Socket, Command),
    case gen_tcp:recv(Socket, 0, 500) of
	{ok,Packet} ->  Packet;
	{error, Reason} -> throw(Reason)
    end.
 
processRequest({get, ["api"]}) -> 
 try 
  gen_web_server:http_reply(301, [{"Location" ,"https://app.swaggerhub.com/apis/scartezini/angraDB/1.0.0"}],[])
 catch  
   Reason -> gen_web_server:http_reply(500, Reason)
 end;  

processRequest({get, ["db", DBName, Id]}) -> 
 try 
  Socket = connect(), 
  _Res1  = sendCommand(Socket, "connect " ++ DBName),
  Packet = sendCommand(Socket, "lookup " ++ Id),
  gen_tcp:close(Socket),
  gen_web_server:http_reply(200, Packet)
 catch  
   Reason -> gen_web_server:http_reply(500, Reason)
 end;  

processRequest({get, _}) -> 
 gen_web_server:http_reply(200);
   
processRequest ({post, ["db", DBName, "update", Id| Body]}) ->
 try 
   Socket = connect(),
   _Res1  = sendCommand(Socket, "connect " ++ DBName),
   Packet = sendCommand(Socket, "update " ++ Id ++ " " ++ Body), 
   gen_tcp:close(Socket),
   gen_web_server:http_reply(200)
 catch
   Reason -> gen_web_server:http_reply(500, Reason)
 end;

processRequest ({post, ["db", DBName, "doc"| Body]}) ->
 try 
   Socket = connect(),
   _Res1  = sendCommand(Socket, "connect " ++ DBName),
   Packet = sendCommand(Socket, "save " ++ Body), 
   gen_tcp:close(Socket),
   gen_web_server:http_reply(200, Packet)
 catch
   Reason -> gen_web_server:http_reply(500, Reason)
 end;

processRequest ({post, ["db", "create"| Body]}) ->
 try 
   Socket = connect(),
   Packet  = sendCommand(Socket, "create_db " ++ Body),
   gen_tcp:close(Socket),
   gen_web_server:http_reply(200, Packet)
 catch
   Reason -> gen_web_server:http_reply(500, Reason)
 end;
 	           
processRequest ({delete, ["db", DBName, Id]}) ->
 try 
   Socket = connect(),
   _Res1  = sendCommand(Socket, "connect " ++ DBName),
   _Res2  = sendCommand(Socket, "delete " ++ Id),
   gen_tcp:close(Socket),
   gen_web_server:http_reply(200)
 catch
   Reason -> gen_web_server:http_reply(500, Reason)
 end;

processRequest ({delete, ["db", DBName]}) ->
 try 
   Socket = connect(),
   _Res1  = sendCommand(Socket, "connect_db " ++ DBName),
   Packet  = sendCommand(Socket, "delete_db " ++ DBName),
   gen_tcp:close(Socket),
   gen_web_server:http_reply(200, Packet)
 catch
   Reason -> gen_web_server:http_reply(500, Reason)
 end;

processRequest ({post, A}) -> 
    gen_web_server:http_reply(400, "Bad request"), 
    io:format("~p ~n", [A]). 
    
printElements([]) -> io:format("]~n", []); 
printElements([H|Tail]) -> io:format("~p",[H]), 
			   printElements(Tail).
		 
