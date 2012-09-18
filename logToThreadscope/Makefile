all:
	gcc -c EventLog.c
	gcc -c logToThreadscope.c
	gcc -o logToThreadscope EventLog.o logToThreadscope.o
clean:
	rm -f *.o logToThreadscope
