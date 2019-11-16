all:
	flex -o agnes.l.cpp agnes.l
	bison -d agnes.y -o agnes.y.cpp
	g++ -o agnes.Ag agnes.l.cpp agnes.y.cpp -w
	rm agnes.l.cpp agnes.y.cpp agnes.y.hpp
	./agnes.Ag example/test.a
