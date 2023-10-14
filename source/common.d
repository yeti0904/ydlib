/// Module for common functions missing from Phobos
module ydlib.common;

import std.uni;

/// converts a string to uppercase
string StringToUpper(string str) {
	string ret;

	foreach (ref ch ; str) {
		ret ~= ch.toUpper();
	}

	return ret;
}

/// converts a string to lower case
string StringToLower(string str) {
	string ret;

	foreach (ref ch ; str) {
		ret ~= ch.toLower();
	}

	return ret;
}

/**
converts an array of bytes to a string with hexadecimal

the upper argument is whether the hexadecimal letters will be uppercase or not
*/
string BytesToString(ubyte[] bytes, bool upper = true) {
	string ret;
	string hex = upper? "0123456789ABCDEF" : "0123456789abcdef";

	foreach (ref b ; bytes) {
		ret ~= hex[b / 16];
		ret ~= hex[b % 16];
	}

	return ret;
}
