module utils;

string formatString(string fmt, string[string] values) {
    import std.array: join;
    string[] parts = [];
    int i = 0, j = 0;
    while (j < fmt.length) {
        if (fmt[j] != '$') {
            j += 1;
            continue;
        }
        parts ~= fmt[i .. j];
        j += 1;
        if (fmt[j] == '(') {
            j += 1;
            i = j;
            while (j < fmt.length && fmt[j] != ')') {
                j += 1;
            }
            parts ~= values[fmt[i .. j]];
            j += 1;
            i = j;
        } else if (fmt[j] == '$') {
            parts ~= "$";
            j += 1;
            i = j;
        }
    }
    if (i < fmt.length) {
        parts ~= fmt[i .. $];
    }
    return parts.join("");
}