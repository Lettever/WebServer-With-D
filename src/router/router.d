module router;
import std.uni;
import std.stdio;
import std.typecons;

alias HTTP_req = string;
alias Route = string;
alias Render_Fn = string function();

class Router {
    Render_Fn[Route][HTTP_req] routes;
    void add(HTTP_req req, Route route, Render_Fn fn) {
        HTTP_req a = req.toUpper();
        if(a in routes && route in routes[a]) {
            writefln("overiding function (%s, %s)", a, route);
        }
        routes[req.toUpper()][route] = fn;
    }

}