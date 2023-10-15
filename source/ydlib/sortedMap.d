/// module for a sorted map class
module ydlib.sortedMap;

import std.format;

/// exception used for sorted map errors
class SortedMapException : Exception {
	this(string msg, string file = __FILE__, size_t line = __LINE__) {
		super(msg, file, line);
	}
}

private struct MapEntry(T1, T2) {
	T1 key;
	T2 value;
}

/// sorted map class
class SortedMap(T1, T2) {
	private MapEntry!(T1, T2)[] entries;

	this() {
		
	}

	/// overrides in keyword
	T2* opBinaryRight(string op: "in")(T1 key) {
		foreach (ref e ; entries) {
			if (e.key == key) {
				return &e.value;
			}
		}

		return null;
	}

	/// overrides index
	T2 opIndex(T1 key) {
		auto ret = key in this;

		if (ret is null) {
			throw new SortedMapException("Key not found in sorted map");
		}

		return *ret;
	}

	/// overrides assigning to index
	void opIndexAssign(T2 value, T1 key) {
		auto entry = MapEntry!(T1, T2)(key, value);

		foreach (i, ref e ; entries) {
			if (e.key > key) {
				if (i == 0) {
					entries = entry ~ entries;
				}
				else {
					entries = entries[0 .. i] ~ entry ~ entries[i .. $];
				}
				return;
			}
		}

		entries ~= entry;
	}

	/// overrides foreach loops
	int opApply(scope int delegate(T1 key, ref T2 value) dg) {
		foreach (ref e ; entries) {
			int result = dg(e.key, e.value);

			if (result) {
				return result;
			}
		}

		return 0;
	}
}
