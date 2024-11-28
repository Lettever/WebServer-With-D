module router;
import std.uni;
import std.stdio;
import std.typecons;

alias HTTP_req = string;
alias Route = string;
alias Render_fn = string function();
class Router {
    Render_fn[Route][HTTP_req] routes;
    void add(HTTP_req req, Route route, Render_fn fn) {
        HTTP_req a = req.toUpper();
        if(a in routes && route in routes[a]) {
            writefln("overiding function (%s, %s)", a, route);
        }
        routes[req.toUpper()][route] = fn;
    }

}