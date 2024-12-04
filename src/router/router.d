module router;
import std.uni;
import std.stdio;
import std.typecons;

alias HTTPReq = string;
alias Route = string;
alias RenderFn = string function();
/*
    route examples:
        /index/foo
        /users/:id/
        id can be anything
*/
class Router {
    RenderFn[Route][HTTPReq] routes;
    void add(HTTPReq req, Route route, RenderFn fn) {
        HTTPReq a = req.toUpper();
        if(a in routes && route in routes[a]) {
            writefln("overiding function (%s, %s)", a, route);
        }
        routes[req.toUpper()][route] = fn;
    }

}