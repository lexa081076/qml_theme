import QtQuick
import SddmComponents 2.0

Rectangle {
    id: container
    width: 1920
    height: 1080
    color: "#111111"

    FontLoader {
        id: winFont
        source: "fonts/tahoma.ttf"
    }

    Connections {
        target: sddm

        // Если вход не удался (пароль неверный)
        onLoginFailed: {
            passwordField.text = "" // Очищаем поле ввода
            errorMessageText.visible = true // Показываем ошибку
            passwordField.forceActiveFocus()
        }

        // Если всё успешно, скрываем ошибку на время анимации скрытия экрана
        onLoginSucceeded: {
            errorMessageText.visible = false
        }
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

        // ВНУТРЕННЕЕ ОКНО
        Rectangle {
            id: loginBox
            anchors.fill: parent
            anchors.margins: 6
            radius: 8
            color: "#E6000000"

            // Глянцевый блик
            Rectangle {
                id: glassGlint
                anchors.fill: parent
                radius: 8
                clip: true
                z: 1
                visible: true
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#1EFFFFFF" }
                    GradientStop { position: 0.45; color: "#0AFFFFFF" }
                    GradientStop { position: 0.46; color: "#00FFFFFF" }
                    GradientStop { position: 1.0; color: "#00FFFFFF" }
                }
            }

            // Основной контейнер элементов
            Item {
                id: contentItem
                anchors.fill: parent
                anchors.margins: 25
                z: 2

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
                                    font.family: winFont.font.family
                                }

                                Text {
                                    id: hintText
                                    text: (typeof model.hint !== "undefined" && model.hint !== "")
                                    ? "Подсказка: " + model.hint
                                    : "Подсказка: Вспоминай давай! :)"
                                    color: "#FFCC00"
                                    font.pixelSize: 15
                                    font.italic: true
                                    visible: false
                                    width: parent.width
                                    font.family: winFont.font.family
                                }

                                // Уведомление о неверном пароле в стиле XP
                                Text {
                                    id: errorMessageText
                                    text: "Неверный пароль. Попробуйте еще раз."
                                    color: "#FF3B30"
                                    font.pixelSize: 13
                                    font.bold: true
                                    visible: false
                                    width: parent.width
                                    font.family: winFont.font.family
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
                                            font.family: winFont.font.family

                                            onTextChanged: errorMessageText.visible = false

                                            onAccepted: {
                                                if (passwordField.text.trim() === "") {
                                                    errorMessageText.text = "Введите пароль!";
                                                    errorMessageText.visible = true;
                                                } else {
                                                    sddm.login(model.name, passwordField.text, sddm.sessionIndex)
                                                }
                                            }
                                        }
                                    }

                                    // Кнопка подсказки (вопрос)
                                    Image {
                                        id: hintButton
                                        width: 28
                                        height: 28
                                        source: hintMouseArea.containsMouse
                                        ? "buttons/login/Bitmap_106.png"
                                        : "buttons/login/Bitmap_105.png"
                                        fillMode: Image.PreserveAspectFit
                                        scale: hintMouseArea.pressed ? 0.9 : 1.0

                                        Behavior on scale { NumberAnimation { duration: 50 } }

                                        MouseArea {
                                            id: hintMouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: hintText.visible = !hintText.visible
                                        }
                                    }

                                    // Кнопка входа (стрелка)
                                    Image {
                                        id: loginButton
                                        width: 28
                                        height: 28
                                        source: loginMA.containsMouse ? "buttons/login/Bitmap_104.png" : "buttons/login/Bitmap_103.png"
                                        fillMode: Image.PreserveAspectFit
                                        scale: loginMA.pressed ? 0.9 : 1.0
                                        Behavior on scale { NumberAnimation { duration: 50 } }
                                        MouseArea {
                                            id: loginMA
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (passwordField.text.trim() === "") {
                                                    errorMessageText.text = "Введите пароль!";
                                                    errorMessageText.visible = true;
                                                } else {
                                                    sddm.login(model.name, passwordField.text, sddm.sessionIndex)
                                                }
                                            }
                                        }
                                    }

                                }
                            }
                        }
                    }
                }
                // НИЖНЯЯ ПАНЕЛЬ
                Item {
                    id: bottomBar
                    width: parent.width
                    height: 30
                    anchors.bottom: parent.bottom
                    // Session переключатель
                    Text {
                        id: sessionText

                        // Обновленная функция с определением X11 / Wayland
                        function getCleanSessionName() {
                            // 1. Проверяем, существует ли вообще модель (чтобы не было undefined при тестах)
                            if (typeof sessionModel === "undefined" || sessionModel.rowCount() === 0) {
                                return "Default";
                            }

                            // 2. Достаем сырую строку (путь вроде /usr/share/xsessions/plasmawayland.desktop)
                            let rawPath = sessionModel.data(sessionModel.index(sddm.sessionIndex, 0), Qt.UserRole + 2);
                            if (!rawPath) return "Default";

                            // Переводим в нижний регистр для надежной проверки
                            let lowerPath = rawPath.toLowerCase();

                            // 3. Вырезаем только имя файла без пути и расширения (.desktop)
                            let fileName = rawPath.substring(rawPath.lastIndexOf('/') + 1);
                            fileName = fileName.replace(".desktop", "");

                            // 4. Делаем первую букву заглавной (plasma -> Plasma)
                            let cleanName = fileName.charAt(0).toUpperCase() + fileName.slice(1);

                            // 5. УМНАЯ ПРОВЕРКА НА DISPLAY SERVER:
                            // Если в названии или пути есть слово "wayland"
                            if (lowerPath.indexOf("wayland") !== -1) {
                                // Если имя файла содержало "plasmawayland", убираем "wayland" из корня, чтобы не дублировалось
                                cleanName = cleanName.replace(/wayland/i, "");
                                return cleanName + " (Wayland)";
                            }
                            // Если это Plasma, но не Wayland — значит, это классический X11 (Xorg)
                            else if (lowerPath.indexOf("plasma") !== -1) {
                                return cleanName + " (X11)";
                            }

                            // Для всех остальных сессий (GNOME, XFCE и т.д.) возвращаем просто имя
                            return cleanName;
                        }

                        // Назначаем текст
                        text: "Session: " + getCleanSessionName()

                        color: "#A0FFFFFF"
                        font.underline: true
                        font.pixelSize: 15
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: winFont.font.family

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: sessionText.color = "#FFFFFF"
                            onExited: sessionText.color = "#A0FFFFFF"
                            onClicked: {
                                if (typeof sessionModel !== "undefined" && sessionModel.rowCount() > 0) {
                                    let nextIndex = sddm.sessionIndex + 1
                                    if (nextIndex >= sessionModel.rowCount())
                                        nextIndex = 0
                                        sddm.sessionIndex = nextIndex
                                }
                            }
                        }
                    }

                    // Shutdown Options текст
                    Text {
                        id: shutdownText
                        text: "Shutdown Options"
                        color: "#A0FFFFFF"
                        font.underline: true
                        font.pixelSize: 15
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: winFont.font.family
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: shutdownText.color = "#FFFFFF"
                            onExited: shutdownText.color = "#A0FFFFFF"
                            onClicked: shutdownDialog.visible = true
                        }
                    }
                }
            }
        }
    }
    // Подключаем диалоговое окно выключения
    ShutdownDialog {
        id: shutdownDialog
        fontFamily: winFont.font.family
        onPowerOffRequested: sddm.powerOff()
        onRebootRequested: sddm.reboot()
        onSuspendRequested: sddm.suspend()
    }
}
