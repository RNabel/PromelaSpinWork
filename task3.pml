byte x=1;
byte y=0;

#define xIsOdd ( x % 2 == 1 )
#define xLeqY ( x <= y )
#define xNeqY ( x != y )
#define xEqY ( x == y )

ltl partA { []xIsOdd }

ltl partB { <>[] xIsOdd }

ltl partC { <>[]<> xIsOdd }

ltl partD { [] xLeqY }

ltl partE { [] (xEqY -> <>xNeqY) }

active proctype P1(){
	do
	:: x=x+2
	od;
}

active proctype P2(){
	do
	:: x=x+1
	od;
}


active proctype P3(){
	do
	:: y<x -> y=x
	od;
}
