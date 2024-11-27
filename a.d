import std.stdio;
import std.traits;

int level = 1;

struct Logger {
    string message;
    int level;
}
@Logger("test1", 2)
void function1() {
    writeln("function 1");
}

@Logger("test2", 0)
void function2() {
    throw new Exception("foo");
    //writeln("function 2");
}

void tryAndLog(void function() fn) {
    Logger log;
    static if(hasUDA!(fn, Logger)) {
        log = getUDAs!(fn, Logger)[0];
        try {
            fn();
        } catch (Exception e) {
            writeln(log);
            writeln(e.message);
            writeln(e.msg);
        }
    }
}
void tryAndLog2() {
    Logger log;
    static if(hasUDA!(function2, Logger)) {
        log = getUDAs!(function2, Logger)[0];
        try {
            function2();
        } catch (Exception e) {
            writeln(log);
            writeln(e.message);
            writeln(e.msg);
        }
    }
}
void tryAndLog1() {
    Logger log;
    static if(hasUDA!(function1, Logger)) {
        log = getUDAs!(function1, Logger)[0];
        try {
            function1();
        } catch (Exception e) {
            writeln(log);
            writeln(e.message);
            writeln(e.msg);
        }
    }
}

// Define a custom UDA
struct MyAttribute {
    string description;
    int level;
}

// Attach UDA to a function
@MyAttribute("This is a special function", 1)
void myFunction() {
    writeln("Hello from myFunction!");
}

void main() {
    // Call the function
    tryAndLog(&function1);
    tryAndLog(&function2);
    tryAndLog1();
    tryAndLog2();
    
    myFunction();
    static if (hasUDA!(myFunction, MyAttribute)) {
        writeln("myFunction has MyAttribute UDA!");
        MyAttribute attr = getUDAs!(myFunction, MyAttribute)[0];
        writeln(attr);
        writeln(attr.description);
        writeln(attr.level);
    }
}