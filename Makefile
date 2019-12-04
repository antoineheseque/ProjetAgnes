program:
	bison -d agnes.y -o agnes.y.cpp
	flex -o agnes.l.cpp agnes.l
	g++ -std=c++1z -o agnes.Ag agnes.l.cpp agnes.y.cpp -w -lsfml-graphics -lsfml-window -lsfml-system -I/usr/include/python2.7 -lpython2.7 -ljsoncpp -lcurl
	chmod a+x agnes.Ag
	rm agnes.l.cpp agnes.y.cpp agnes.y.hpp

compiler:
	cd GUI && $(MAKE)
	chmod a+x GUI/editor
	./GUI/editor
