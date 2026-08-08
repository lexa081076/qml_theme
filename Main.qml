import QtQuick 2.0
import SddmComponents 2.0

Rectangle {
    id: container
    width: 1920
    height: 1080
    color: "#111111"
        // ЭТОТ БЛОК ДОБАВЛЯЕМ В НАЧАЛО ФАЙЛА
    FontLoader {
        id: winFont
        source: "tahoma.ttf" // Укажите имя вашего файла (tahoma.ttf или segoeui.ttf)
    }

    // Фоновое изображение
    Image {
        id: bg
        anchors.fill: parent
        source: "background.jpg"
        fillMode: Image.PreserveAspectCrop
    }

    // ВНЕШНЯЯ РАМКА AERO GLASS
    Rectangle {
        id: aeroFrame
        width: 580
        height: 420
        anchors.centerIn: parent
        radius: 12
        border.width: 1
        border.color: "#60FFFFFF"

        gradient: Gradient {
            GradientStop { position: 0.0; color: "#40FFFFFF" }
            GradientStop { position: 0.4; color: "#15FFFFFF" }
            GradientStop { position: 1.0; color: "#25000000" }
        }

// ВНУТРЕННЕЕ ОКНО, ТЕПЕРЬ НА НАСТОЯЩЕЙ ТЕКСТУРЕ ИЗ ПОТРОХОВ
        Rectangle {
            id: loginBox
            anchors.fill: parent
            anchors.margins: 6
            radius: 8
            color: "transparent" // Отключаем кодовую заливку, она больше не нужна

            // ТА САМАЯ ОРИГИНАЛЬНАЯ РАМКА-СТЕКЛО
            Image {
                id: originalFrame
                anchors.fill: parent
                source: "Bitmap_101.png" // Сюда впишите имя файла найденной рамки!
                fillMode: Image.Stretch // Мягко растянет текстуру под размер окна
            }

            // Наш глянцевый блик можно оставить, если оригинальная картинка без него, 
            // или просто отключить (visible: false), если на картинке уже есть свой блик
            Rectangle {
                id: glassGlint
                anchors.fill: parent
                radius: 8
                clip: true
                z: 1
                visible: true // Поиграйтесь с true/false, как лучше смотрится
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#1EFFFFFF" } 
                    GradientStop { position: 0.45; color: "#0AFFFFFF" }
                    GradientStop { position: 0.46; color: "#00FFFFFF" } 
                    GradientStop { position: 1.0; color: "#00FFFFFF" }
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 25
                spacing: 15
                z: 2 // Поднимаем текст и кнопки НАД оригинальной рамкой и бликом
                
            // Основной контейнер элементов
            Item {
                anchors.fill: parent
                anchors.margins: 25
                z: 1

                ListView {
                    id: userList
                    width: parent.width
                    height: parent.height - 40
                    anchors.top: parent.top
                    model: userModel
                    currentIndex: userModel.lastIndex
                    clip: true
                    spacing: 12

                    delegate: Item {
                        width: userList.width
                        // Высота слота увеличивается, если включена подсказка
                        height: userList.currentIndex === index ? (hintText.visible ? 125 : 95) : 55

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                userList.currentIndex = index
                                passwordField.forceActiveFocus()
                            }
                        }

                        Row {
                            anchors.fill: parent
                            spacing: 15

                            // Аватар
                            Rectangle {
                                width: 50
                                height: 50
                                color: "#1a1a1a"
                                border.color: userList.currentIndex === index ? "#0078D7" : "#44FFFFFF"
                                border.width: 1

                                Text {
                                    text: "👤"
                                    color: "#88FFFFFF"
                                    font.pixelSize: 24
                                    anchors.centerIn: parent
                                    visible: !userIcon.visible

                                }

                                Image {
                                    id: userIcon
                                    anchors.fill: parent
                                    anchors.margins: 2
                                    source: model.icon || ""
                                    fillMode: Image.PreserveAspectCrop
                                    visible: model.icon !== "" && status === Image.Ready
                                }
                            }

                            // Имя, пасхалка и ввод
                            Column {
                                width: parent.width - 65
                                spacing: 6

                                Text {
                                    text: model.realName === "" ? model.name : model.realName
                                    color: "#FFFFFF"
                                    font.bold: true
                                    font.pixelSize: 15
                                    font.family: winFont.name
                                }

                                // ТЕКСТ ПАСХАЛКИ
                                Text {
                                    id: hintText
                                    text: "Подсказка: Вспоминай давай!"
                                    color: "#FFCC00"
                                    font.pixelSize: 15
                                    font.italic: true
                                    visible: false
                                    width: parent.width
                                    font.family: winFont.name
                                }

                                Row {
                                    width: parent.width
                                    spacing: 8
                                    visible: userList.currentIndex === index

                                    // Поле ввода
                                    Rectangle {
                                        width: 215
                                        height: 28
                                        color: "#FFFFFF"
                                        border.color: passwordField.activeFocus ? "#0078D7" : "#888888"
                                        border.width: passwordField.activeFocus ? 2 : 1
                                        radius: 2

                                        TextInput {
                                            id: passwordField
                                            anchors.fill: parent
                                            anchors.margins: 6
                                            echoMode: TextInput.Password
                                            focus: userList.currentIndex === index
                                            selectByMouse: true
                                            color: "#000000"
                                            font.pixelSize: 15
                                            font.family: winfont.name

                                            onAccepted: sddm.login(model.name, passwordField.text, sddm.sessionIndex)
                                        }
                                    }

                                    // 1. ОРИГИНАЛЬНАЯ КНОПКА ЗНАКА ВОПРОСА С ЭФФЕКТОМ HOVER
                                    Image {
                                        id: hintButton
                                        width: 28
                                        height: 28
                                        // Если мышь наведена — берем 106, иначе — 105
                                        source: hintMouseArea.containsMouse ? "Bitmap_106.png" : "Bitmap_105.png"
                                        fillMode: Image.PreserveAspectFit
                                        scale: hintMouseArea.pressed ? 0.9 : 1.0

                                        Behavior on scale { NumberAnimation { duration: 50 } }

                                        MouseArea {
                                            id: hintMouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: hintText.visible = !hintText.visible
                                        }
                                    }

                                    // 2. ОРИГИНАЛЬНАЯ КНОПКА ВХОДА (СТРЕЛКА) С ЭФФЕКТОМ HOVER
                                    Image {
                                        id: loginButton
                                        width: 28
                                        height: 28
                                        // Если мышь наведена — берем 104, иначе — 103
                                        source: loginMouseArea.containsMouse ? "Bitmap_104.png" : "Bitmap_103.png"
                                        fillMode: Image.PreserveAspectFit
                                        scale: loginMouseArea.pressed ? 0.9 : 1.0

                                        Behavior on scale { NumberAnimation { duration: 50 } }

                                        MouseArea {
                                            id: loginMouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: sddm.login(model.name, passwordField.text, sessionIndex)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

 // НИЖНЯЯ ПАНЕЛЬ
                Item {
                    width: parent.width
                    height: 30
                    anchors.bottom: parent.bottom

                    Text {
                        id: sessionText
                        text: "Session: " + (typeof sessionModel !== 'undefined' ? sddm.sessionIndex : "0")
                        color: "#A0FFFFFF"
                        font.underline: true
                        font.pixelSize: 15
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: winfont.name

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: sessionText.color = "#FFFFFF"
                            onExited: sessionText.color = "#A0FFFFFF"
                            onClicked: {
                                if (typeof sessionModel !== 'undefined' && sessionModel.rowCount() > 0) {
                                    var nextIndex = sddm.sessionIndex + 1;
                                    if (nextIndex >= sessionModel.rowCount()) nextIndex = 0;
                                    sddm.sessionIndex = nextIndex;
                                }
                            }
                        }
                    }

Text {
    text: "Shutdown Options"
    color: "#A0FFFFFF"
    font.underline: true
    font.pixelSize: 15
    anchors.horizontalCenter: parent.horizontalCenter // Сразу по центру
    anchors.verticalCenter: parent.verticalCenter
    font.family: winfont.name

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: shutdownText.color = "#FFFFFF"
        onExited: shutdownText.color = "#A0FFFFFF"
        // Вызывает стандартное системное меню SDDM со всеми кнопками (выключение, ребут, сон)
        onClicked: sddm.powerOff()
    }
}
                }
            }
        }
    }
}
