/// module for serialisation/deserialisation for files or other uses
module ydlib.serialise;

import std.string;
import std.bitmanip;

/// type of a value (integer/string/structure)
enum ValueType {
	Integer   = 0x00,
	String    = 0x01,
	Structure = 0x02
}

/// flags used for different variations of a value
enum Flags {
	Array = 0b00000001
}

/// contents of a value
union ValueContents {
	int    _int;
	string _string;

	this(int pint) {
		_int = pint;
	}

	this(string pstring) {
		_string = pstring;
	}
}

/// main value structure
struct Value {
	ValueType type;
	bool      isArray;

	union {
		ValueContents   single;
		ValueContents[] array;
		Structure       structure;
	}

	/// makes a value from an integer
	this(int from) {
		type     = ValueType.Integer;
		isArray  = false;
		single   = ValueContents(from);
	}

	/// makes a value from a string
	this(string from) {
		type     = ValueType.String;
		isArray  = false;
		single   = ValueContents(from);
	}

	/// makes a value from an integer array
	this(int[] from) {
		type    = ValueType.Integer;
		isArray = true;

		foreach (ref val ; from) {
			array ~= ValueContents(val);
		}
	}

	/// makes a value from a string array
	this(string[] from) {
		type    = ValueType.String;
		isArray = true;

		foreach (ref val ; from) {
			array ~= ValueContents(val);
		}
	}

	/// makes a value from a structure
	this(Structure from) {
		type      = ValueType.Structure;
		isArray   = false;
		structure = from;
	}

	/// makes a value from an integer
	static Value Int(int from = 0) {
		return Value(from);
	}

	/// makes a value from a string
	static Value String(string from = "") {
		return Value(from);
	}

	/// makes a value from an integer array
	static Value IntArray(int[] from = []) {
		return Value(from);
	}

	/// makes a value from a string array
	static Value StringArray(string[] from = []) {
		return Value(from);
	}

	/// returns the value's contents as an integer
	int GetInt() {
		assert(type == ValueType.Integer);
		assert(!array);

		return single._int;
	}

	/// returns the value's contents as a string
	string GetString() {
		assert(type == ValueType.String);
		assert(!array);

		return single._string;
	}

	/// returns the value's contents as an integer array
	int[] GetIntArray() {
		assert(type == ValueType.Integer);
		assert(array);

		int[] ret;

		foreach (ref val ; array) {
			ret ~= val._int;
		}

		return ret;
	}

	/// returns the value's contents as a string array
	string[] GetStringArray() {
		assert(type == ValueType.String);
		assert(array);

		string[] ret;

		foreach (ref val ; array) {
			ret ~= val._string;
		}

		return ret;
	}
}

/// structures are just arrays of values
alias Structure = Value[];

/// exception for DataManager methods
class DataException : Exception {
	this(string msg, string file = __FILE__, size_t line = __LINE__) {
		super(msg, file, line);
	}
}

/// main class for data from a file etc
class DataManager {
	Structure[string] structures;

	/// adds a structure type
	void AddStructure(string name, Structure structure) {
		structures[name] = structure;
	}

	/// checks if a structure is valid
	bool ValidStructure(string name, Structure structure) {
		Structure type = structures[name];

		if (structure.length != type.length) {
			return false;
		}

		foreach (i, ref val ; structure) {
			if (val.type != type[i].type) {
				return false;
			}
		}

		return true;
	}

	/// turns the data into an array of bytes
	ubyte[] Serialise(Structure structure) {
		ubyte[] ret;

		ret ~= nativeToBigEndian(cast(ulong) structure.length);
		
		foreach (ref val ; structure) {
			ret ~= cast(ubyte) val.type;

			ubyte flags;

			if (val.isArray) {
				flags |= cast(ubyte) Flags.Array;
			}

			ret ~= flags;
			
			if (val.isArray) {
				ret ~= nativeToBigEndian(cast(ulong) val.array.length);
			}
		
			switch (val.type) {
				case ValueType.Integer: {
					if (val.isArray) {
						foreach (ref val2 ; val.array) {
							ret ~= nativeToBigEndian(val2._int);
						}
					}
					else {
						ret ~= nativeToBigEndian(val.single._int);
					}
					break;
				}
				case ValueType.String: {
					if (val.isArray) {
						foreach (ref val2 ; val.array) {
							ret ~= val2._string ~ 0;
						}
					}
					else {
						ret ~= val.single._string;
					}
					break;
				}
				case ValueType.Structure: {
					ret ~= Serialise(val.structure);
					break;
				}
				default: assert(0);
			}
		}

		return ret;
	}

	/// creates data from an array of bytes
	Structure Deserialise(ref ubyte[] data) {
		Structure ret;

		ulong length = bigEndianToNative!ulong(data[0 .. 8]);
		data         = data[8 .. $];

		while ((data.length > 0) && (ret.length < length)) {
			switch (cast(ValueType) data[0]) {
				case ValueType.Integer: {
					if (data[1] & Flags.Array) {
						ulong len = bigEndianToNative!ulong(data[2 .. 10]);

						data = data[10 .. $];
						
						Value array;
						array.type    = ValueType.Integer;
						array.isArray = true;

						for (ulong i = 0; i < len; ++i) {
							array.array ~= ValueContents(
								bigEndianToNative!int(data[0 .. 4])
							);
							data = data[4 .. $];
						}

						ret ~= array;
					}
					else {
						ret  ~= Value(bigEndianToNative!int(data[1 .. 5]));
						data  = data[5 .. $];
					}
					break;
				}
				case ValueType.String: {
					string str;

					data = data[1 .. $];

					while (data[0] > 0) {
						str  ~= data[0];
						data  = data[1 .. $];
					}

					data = data[1 .. $]; // remove null terminator

					ret ~= Value(str);
					break;
				}
				case ValueType.Structure: {
					ret ~= Value(Deserialise(data));
					break;
				}
				default: assert(0);
			}
		}

		return ret;
	}
}
