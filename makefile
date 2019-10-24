all:
	bison -d agnes.y
	flex agnes.l
	gcc agnes.tab.c lex.yy.c -o agnes.Ag -lm
	rm agnes.tab.c agnes.tab.h lex.yy.c
	./agnes.Ag
