# AngraDB Web

This is the http interface of Angra-DB, and consists of a
symple REST based erlang implementation of a generic web
server detailed in Erlang and OTP in Action (Martin Logan et al.).

## Status

Under development. It has not been integrated to the AngraDB Core
module. This activity must be carried out as soon as possible.
In addition, it only answers to HTTP GET request with the
standar messat It works!

## How to start the http server

Clone the repository and run the following commands:

    $ rebar3 shell
    erlang> adb_web:start().

Than, using curl or a web browser, send an HTTP GET request
to http://localhost:4321

## Task List

- [x] Basic server running and accepting HTTP GET requests 
- [ ] Integrate with the AngraDB Core module (supporting the expected methods: GET, POST, PUT DELETE)
- [ ] Start the dependent modules automatically (lager, for instance)

