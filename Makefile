all:
	rm agnes.cpp agnes.h
	flex -o agnes.cpp agnes.l
	g++ agnes.cpp -o agnes
	./agnes
