#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDir>
#include "tcpclienthandler.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // Регистрируем C++ класс
    qmlRegisterType<TcpClientHandler>("FileClient", 1, 0, "TcpClientHandler");

    QQmlApplicationEngine engine;

    // Загрузка QML из файла
    engine.load(QUrl::fromLocalFile("D:/QtProject/MyClient/Main.qml"));

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
