calculator:-
 write('Operations Supported: 1. addition 2. subtraction 3. multiplication 4. division 5. mod 6. squareRoot'),
 nl,
 write('What do you want to do?'),
 read(O),
 write('Operand 1: '),
 read(X),
   (O='squareRoot'->Answer is sqrt(X), write(Answer);
   write('Operand 2: '),
   read(Y),
    (O='addition'->Answer is X+Y, write(Answer);
    (O='subtraction'->Answer is X-Y, write(Answer);
    (O='multiplication'->Answer is X*Y, write(Answer);
    (O='division'->Answer is X/Y, write(Answer);
    (O='mod'->Answer is mod(X,Y), write(Answer))))))).
