# ydlib
Yeti's D Library

Some useful stuff I made for D

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
