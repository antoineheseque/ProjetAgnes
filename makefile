all:
	bison -d agnes.y -o agnes.y.cpp
	flex -o agnes.l.cpp agnes.l
	g++ -o agnes.Ag agnes.l.cpp agnes.y.cpp -w
	rm agnes.l.cpp agnes.y.cpp agnes.y.hpp
	./agnes.Ag example/test.a
