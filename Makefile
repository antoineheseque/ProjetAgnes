program:
	bison -d agnes.y -o agnes.y.cpp
	flex -o agnes.l.cpp agnes.l
	g++ -o agnes.Ag agnes.l.cpp agnes.y.cpp -w -lsfml-graphics -lsfml-window -lsfml-system
	sudo chmod a+x agnes.Ag
	rm agnes.l.cpp agnes.y.cpp agnes.y.hpp

compiler:
	cd GUI && $(MAKE)
	chmod a+x GUI/editor
	./GUI/editor
