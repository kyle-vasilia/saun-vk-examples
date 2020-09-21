module saun.util.conv;
import std.string;

import std.algorithm;
import std.range;

string[] to(const(char)*[] arr) {
    import iTo = std.conv: to;
    string[] toArr = new string[arr.length];
    foreach(cStr, ref str; lockstep(arr, toArr)) {
        str = iTo.to!string(cStr);
    }
    return toArr;
}

const(char)*[] to(string[] arr) {
    const(char)*[] toArr = new const(char)*[arr.length];
    foreach(ref cStr, str; lockstep(toArr, arr)) {
        cStr = str.toStringz;
    }
    return toArr;
}