// Print variables.
#define PROC_NUM 10
bool print_vars[PROC_NUM] = false;
byte total = 0;

// Channels acting as muteces.
chan print_mutex = [1] of {bit};

proctype proc (byte index) {
	bit temp = 0;

	// Acquire mutex. -- CRITICAL SECTION START.
	print_mutex ! 1;

	// Set print flag in array.
	print_vars[index] = true;
	total++;
	
	printf("Process %d has control.\n", index);
	
	// Reset print flag in array.
	print_vars[index] = false;
	total--;

	// Release mutex. -- CRITICAL SECTION END.
	print_mutex ? temp;
}


// Requires fixing, currently not used by tester.
never {
	do
	:: (total > 1) -> break;
	:: else
	od;
}


init {
	byte curr_index = 0;
	
	// Start N processes.
	curr_index = 0;
	do
	:: (curr_index < 10) -> run proc(curr_index); curr_index = curr_index + 1;
	:: else -> break;
	od;
}