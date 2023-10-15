# ydlib
Yeti's D Library

Some useful stuff I made for D

Links:
- [Dub package page](https://code.dlang.org/packages/ydlib) (Includes documentation)

# Install
```
dub add ydlib
```

# Libraries
## ydlib.serialise
TODO: Explain this completely untested library

## ydlib.sortedMap
This module gives you a sorted map class

### Example
```
import std.stdio;
import ydlib.sortedMap;

void main() {
	// first int is key type
	// second is value type
	auto map = new SortedMap!(int, int)();

	map[0] = 6;
	map[2] = 9;
	map[1] = 0;

	foreach (key, ref value ; map) {
		writefln("%d: %d", key, value);
	}
}
```

## ydlib.common
Contains common functions that are missing from Phobos

Has a variety of functions, best to look at the documentation

## ydlib.list
Contains a doubly linked list class

### Example
```
import std.stdio;
import ydlib.list;

void main() {
	auto myList = new List!int();

	myList ~= 1;
	myList ~= 2;
	myList ~= 3;

	foreach (num ; myList) {
		if (num.value % 2 == 0) {
			num.InsertAfter(5);
		}
	}

	foreach (num ; myList) {
		writeln(num.value);
	}
}
```
