#include <SFML/Graphics.hpp>
#include "src/TextView.h"
#include "src/TextDocument.h"
#include "src/InputController.h"
#include "src/ImplementationUtils.h"
#include <string>
#include <iostream>

bool isSpriteHover(sf::FloatRect sprite, sf::Vector2f mp)
{
        if (sprite.contains(mp)){
        return true;
        }
        return false;
}

int main(int argc, char* argv[]) {

    std::string workingDirectory = ImplementationUtils::getWorkingDirectory(argv[0]);

    std::string saveFileName;
    std::string loadFileName;

    std::cout << "Entrez le nom du fichier à éditer/sauvegarder: ";
    std::string str;
    std::getline(std::cin, str);
    saveFileName = workingDirectory + "../example/" + str;
    loadFileName = workingDirectory + "../example/" + str;

    sf::RenderWindow window(sf::VideoMode(720, 405), "Editeur Agnes v1.0.0");
    window.setVerticalSyncEnabled(true);
    sf::Color backgroundColor = sf::Color(21, 29, 45);

    TextView textView(window, workingDirectory);
    TextDocument document;
    InputController inputController;

    document.init(loadFileName);

    // BACKGROUND
    sf::Texture texture;
    if (!texture.loadFromFile("img/index.jpeg"))
    { }
    sf::Sprite background(texture);
    sf::Vector2u size = texture.getSize();
    background.setOrigin(size.x / 2, size.y / 2);
    background.setPosition(sf::Vector2f(sf::VideoMode::getDesktopMode().width/2,sf::VideoMode::getDesktopMode().height/2));

    // BOUTON
    /*sf::Texture texture2;
    if(!texture2.loadFromFile("img/button1.png"))
    {
    }
    sf::Sprite sprite;
    sprite.setTexture(texture2);

    sf::Vector2f mp;
    mp.x = sf::Mouse::getPosition(window).x;
    mp.y = sf::Mouse::getPosition(window).y;*/

    while (window.isOpen()) {
        sf::Event event;
        while (window.pollEvent(event)) {
            /*if(isSpriteHover(sprite.getGlobalBounds(), sf::Vector2f(event.mouseButton.x, event.mouseButton.y)) == true)
            {
              if(event.type == sf::Event::MouseButtonReleased && event.mouseButton.button == sf::Mouse::Left)
              {
                document.saveFile(saveFileName);
                std::cout << "Fichier sauvegardé! " << saveFileName << "\n";
              }
            }*/
            if (event.type == sf::Event::Closed) {
                window.close();
            }
            if (event.type == sf::Event::Resized) {
                textView.setCameraBounds(event.size.width, event.size.height);
            }
            if (event.key.code == sf::Keyboard::S && sf::Keyboard::isKeyPressed(sf::Keyboard::LControl)) {
                if (document.hasChanged()){

                    document.saveFile(saveFileName);
                    std::cout << "Fichier sauvegardé! " << saveFileName << "\n";
                }
            }
            if (event.key.code == sf::Keyboard::B && sf::Keyboard::isKeyPressed(sf::Keyboard::LControl)) {
                if (document.hasChanged()){
                    document.saveFile(saveFileName);
                    std::cout << "Fichier sauvegardé! " << saveFileName << "\n";
                }
                std::cout << "Chargement du fichier ...\n";
                system("cd && make");
                system("./agnes.Ag");
            }

            inputController.handleEvents(document, textView, window, event);
        }

        inputController.handleConstantInput(document, textView, window);

        window.clear(backgroundColor);
        window.setView(textView.getCameraView());
        window.draw(background);
        //window.draw(sprite);
        textView.draw(window, document);
        window.display();
    }

    return 0;
}
