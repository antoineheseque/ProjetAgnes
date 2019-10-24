all:
	bison -d agnes.y
	flex agnes.l
	gcc agnes.tab.c lex.yy.c -o agnes -lm
	#g++ agnes.lex.cpp agnes.bison.cpp -o agnes
	./agnes "example/test.a"
