#define CHANNEL_CAP 1

proctype Sender(chan int1; chan int2) {
	byte current_count = 1;

	do
	:: (current_count < 11) -> 
		if
		:: skip ->  int1 ! current_count;
		:: skip ->	int2 ! current_count;
		fi;
		 
		current_count =  current_count + 1;
	:: else -> break;
	od;

	// Send End of Stream signal on both channels.
	int1 ! 255;
	int2 ! 255;
}

proctype Receiver(chan recv; chan finished) {
	byte count = 0;
	byte temp = 0;
	
	do
	:: (count < 10) ->  recv ? temp; 
		printf("Receiver received new number: %d, new count: %d\n", temp, count);
		count = count + 1;
	:: (count >= 10) -> 
		break;
	od;

	finished ! true;
	printf("Receiver finished.\n");
}


proctype Intermediate(chan inter; chan recv) {
	byte sum, received;
	sum = 0;
	received = 0;

	// Simulate do-while.
	inter ? received;

	do
	:: (received != 255) -> 
		// Increment sum.
		sum = sum + received;
		printf("Intermediate received number: %d, new sum: %d\n", received, sum);
		
		// Send received value on to Receiver.
		recv ! received;
		
		// Read next element in channel.
		inter ? received;
	:: else -> break;
	od;
	
	// End of stream received, send sum.
	inter ! sum;
}

init {
	byte lastpid;

	// Channels to the Intermediate processes.
	chan int1 = [CHANNEL_CAP] of {byte};
	chan int2 = [CHANNEL_CAP] of {byte};

	// Integers to hold sums of Intremediate processes.
	byte sum_of_int1 = 0;
	byte sum_of_int2 = 0;

	// Channel from Intermediate to Receiver.
	chan recv = [CHANNEL_CAP] of {byte};
	chan finished = [CHANNEL_CAP] of {bit};
	
	bit finish = false;

	printf("Init Function executing...\n");
	lastpid = run Sender(int1, int2);

	lastpid = run Receiver(recv, finished);

	lastpid = run Intermediate(int1, recv);
	lastpid = run Intermediate(int2, recv);
	
	// Blocking call to wait until Receiver received expected number of elements.
	finished ? finish;

	int1 ? sum_of_int1;
	int2 ? sum_of_int2;

	printf("Results: int1 %d, int2 %d, sum %d\n", sum_of_int1, sum_of_int2, sum_of_int1 + sum_of_int2);
}
