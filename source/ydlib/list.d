/// module containing a doubly linked list class
module ydlib.list;

/// linked node class
class ListNode(T) {
	/// value before this entry
	ListNode!T previous;
	/// value of this entry
	T value;
	/// value next to this entry
	ListNode!T next;

	this() {
		
	}

	this(T pvalue) {
		value = pvalue;
	}

	/// gets the last entry in the list
	ListNode!T GetLastEntry() {
		ListNode!T current = this;

		while (current.next !is null) {
			current = current.next;
		}

		return current;
	}

	/// appends the value to the end of the list
	void opOpAssign(string op: "~")(T pvalue) {
		auto last = GetLastEntry();

		last.next          = new ListNode!T(pvalue);
		last.next.previous = last;
	}

	/// inserts a value after this entry
	void InsertAfter(T value) {
		auto oldNext = next;

		next             = new ListNode!T(value);
		next.next        = oldNext;
		oldNext.previous = next;
	}

	/// inserts a value before this entry
	void InsertBefore(T value) {
		auto oldPrev = previous;

		previous          = new ListNode!T(value);
		previous.previous = oldPrev;
		previous.next     = this;
		oldPrev.next      = previous;
	}
}

/// linked list class
class List(T) {
	ListNode!T head;

	this() {
		
	}

	/// appends the value to the end of the list
	void opOpAssign(string op: "~")(T value) {
		if (head is null) {
			head = new ListNode!T(value);
		}
		else {
			head ~= value;
		}
	}

	/// overrides foreach loops
	int opApply(scope int delegate(ListNode!T value) dg) {
		ListNode!T current = head;

		while (current !is null) {
			int result = dg(current);

			if (result) {
				return result;
			}
			
			current = current.next;
		}

		return 0;
	}
}
