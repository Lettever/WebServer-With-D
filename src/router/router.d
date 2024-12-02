module router;
import std.uni;
import std.stdio;
import std.typecons;

alias HTTP_req = string;
alias Route = string;
alias RenderFn = string function();

/*
Route example:
    - /index/foo
    - /user/:id
    the id can be anything like
    /user/10
    /user/bye
    /user/1_1
    ...
*/

class Router {
    RenderFn[Route][HTTP_req] routes;
    void add(HTTP_req req, Route route, RenderFn fn) {
        HTTP_req a = req.toUpper();
        if(a in routes && route in routes[a]) {
            writefln("overiding function (%s, %s)", a, route);
        }
        routes[req.toUpper()][route] = fn;
    }

}
