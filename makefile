all:
	bison -d -t agnes.y
	flex agnes.l
	g++ agnes.tab.c lex.yy.c -o agnes.Ag -lm
	rm agnes.tab.c agnes.tab.h lex.yy.c
	./agnes.Ag example/test.a
