import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs // Исправленный импорт
import FileClient 1.0

ApplicationWindow {
    id: mainWindow
    title: "File Transfer Client"
    width: 500
    height: 600
    minimumWidth: 400
    minimumHeight: 400
    visible: true

    TcpClientHandler {
        id: clientHandler
        onFileSentSuccessfully: function(fileName) { // Добавляем явный параметр
            sentFilesModel.append({"fileName": fileName, "status": "✓ Отправлен", "time": new Date().toLocaleTimeString()});
            statusLabel.text = "Файл отправлен: " + fileName;
            statusLabel.color = "green";
            resetStatusTimer.start();
        }
        onErrorOccurred: function(errorMessage) { // И здесь тоже
            statusLabel.text = errorMessage;
            statusLabel.color = "red";
            resetStatusTimer.start();
        }
    }

    ListModel {
        id: sentFilesModel
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        Label {
            Layout.fillWidth: true
            text: "📤 File Transfer Client"
            font.bold: true
            font.pixelSize: 20
            horizontalAlignment: Text.AlignHCenter
        }

        // Статус подключения
        Label {
            id: statusLabel
            Layout.fillWidth: true
            text: clientHandler.status
            color: clientHandler.isConnected ? "green" : "gray"
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
        }

        // Поле для ввода адреса сервера
        GroupBox {
            Layout.fillWidth: true
            title: "🔗 Подключение к серверу"

            GridLayout {
                width: parent.width
                columns: 2
                rowSpacing: 10
                columnSpacing: 10

                Label { text: "IP адрес:" }
                TextField {
                    id: ipField
                    Layout.fillWidth: true
                    placeholderText: "192.168.1.5"
                    text: "192.168.1.5"
                }

                Label { text: "Порт:" }
                TextField {
                    id: portField
                    Layout.preferredWidth: 100
                    placeholderText: "12345"
                    text: "12345"
                    validator: IntValidator { bottom: 1; top: 65535 }
                }

                Button {
                    Layout.columnSpan: 2
                    Layout.fillWidth: true
                    text: clientHandler.isConnected ? "🔌 Отключиться" : "🔗 Подключиться"
                    onClicked: {
                        if (clientHandler.isConnected) {
                            clientHandler.disconnectFromServer();
                        } else {
                            var port = parseInt(portField.text);
                            if (port > 0 && port <= 65535) {
                                clientHandler.connectToServer(ipField.text, port);
                            } else {
                                statusLabel.text = "Неверный порт!";
                                statusLabel.color = "red";
                            }
                        }
                    }
                }
            }
        }

        // Прогресс отправки
        ProgressBar {
            Layout.fillWidth: true
            value: clientHandler.progress / 100
            visible: clientHandler.progress > 0 && clientHandler.progress < 100
            Label {
                anchors.centerIn: parent
                text: clientHandler.progress + "%"
                color: "white"
                font.bold: true
            }
        }

        // Кнопка выбора файла
        Button {
            Layout.fillWidth: true
            text: "📁 Выбрать файл для отправки"
            enabled: clientHandler.isConnected
            onClicked: fileDialog.open()
        }

        // Информация о текущем файле
        Label {
            Layout.fillWidth: true
            text: "Текущий файл: " + (clientHandler.currentFile || "не выбран")
            wrapMode: Text.Wrap
            visible: clientHandler.currentFile
        }

        // Разделитель
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#e0e0e0"
        }

        // История отправленных файлов
        GroupBox {
            Layout.fillWidth: true
            Layout.fillHeight: true
            title: "📋 Отправленные файлы (" + sentFilesModel.count + ")"

            ScrollView {
                anchors.fill: parent
                clip: true

                ListView {
                    width: parent.width
                    model: sentFilesModel
                    spacing: 5

                    delegate: Rectangle {
                        width: ListView.view.width
                        height: 50
                        radius: 5
                        color: index % 2 === 0 ? "#f8f9fa" : "#ffffff"

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 5
                            spacing: 10

                            Label { text: "📤"; font.pixelSize: 16 }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                Label {
                                    text: fileName
                                    elide: Text.ElideMiddle
                                    font.bold: true
                                }
                                Label {
                                    text: "Время: " + time
                                    font.pixelSize: 10
                                    color: "gray"
                                }
                            }

                            Label {
                                text: status
                                color: "green"
                                font.bold: true
                            }
                        }
                    }
                }
            }
        }

        // Кнопка очистки истории
        Button {
            Layout.fillWidth: true
            text: "🧹 Очистить историю"
            enabled: sentFilesModel.count > 0
            onClicked: sentFilesModel.clear()
        }
    }

    // Диалог выбора файла - ИСПРАВЛЕННАЯ ВЕРСИЯ
    // ЗАМЕНИТЕ диалог на этот код:
    FileDialog {
        id: fileDialog
        title: "Выберите файл для отправки"
        nameFilters: ["Все файлы (*)"]

        onAccepted: {
            let filePath = selectedFile.toString();
            // Для Windows убираем "file:///"
            if (filePath.startsWith("file:///")) {
                filePath = filePath.substring(8);
            }
            console.log("Выбран файл:", filePath);
            clientHandler.sendFile(filePath);
        }

        onRejected: {
            console.log("Выбор файла отменен");
        }
    }

    Timer {
        id: resetStatusTimer
        interval: 3000
        onTriggered: {
            statusLabel.text = clientHandler.status;
            statusLabel.color = clientHandler.isConnected ? "green" : "gray";
        }
    }
}
