import QtQuick 2.0

Item {
    id: root
    anchors.fill: parent
    visible: false
    z: 100

    property string fontFamily: "Tahoma"

    signal powerOffRequested()
    signal rebootRequested()
    signal suspendRequested()

    // Полное затемнение заднего плана (в XP задний фон вообще становился черно-белым, делаем сильное затемнение)
    Rectangle {
        anchors.fill: parent
        color: "#99000000"
        MouseArea {
            anchors.fill: parent
            onClicked: root.visible = false
        }
    }

    // Главное каноничное окно диалога выключения
    Image {
        id: dialogFrame
        width: 312
        height: 194 // Увеличили высоту для точного соответствия пропорциям оригинального окна
        source: "shutdown_frame.png" // Используем твою подложку с синими панелями
        anchors.centerIn: parent

        // ЗАГОЛОВОК ОКНА (Текст слева, Эмблема справа)
        Item {
            id: headerArea
            width: parent.width
            height: 38
            anchors.top: parent.top

            Text {
                text: "Выключение компьютера"
                color: "#FFFFFF"
                font.pixelSize: 18 // Крупный заголовок по канону
                font.family: root.fontFamily
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
            }

            Image {
                id: winLogo
                source: "windows_emblem.png"
                width: 48
                height: 36
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                fillMode: Image.PreserveAspectFit
            }
        }

        // ЦЕНТРАЛЬНАЯ ЧАСТЬ: ТРИ КНОПКИ
        Row {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 4 // Небольшое смещение кнопок в центр светлой полосы
            spacing: 28 // Расстояние между кнопками по оригиналу

            // 1. Кнопка: Ждущий режим
            Column {
                spacing: 8
                Image {
                    width: 32; height: 32
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: suspendMA.pressed
                    ? "buttons/shutdown/button_4.png"
                    : (suspendMA.containsMouse ? "buttons/shutdown/button_5.png" : "buttons/shutdown/button_3.png")

                    MouseArea {
                        id: suspendMA
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { root.suspendRequested(); root.visible = false }
                    }
                }
                Text {
                    text: "Ждущий режим";
                    font.pixelSize: 11;
                    font.family: root.fontFamily;
                    color: "#FFFFFF";
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            // 2. Кнопка: Выключение
            Column {
                spacing: 8
                Image {
                    width: 32; height: 32
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: shutdownMA.pressed
                    ? "buttons/shutdown/button_1.png"
                    : (shutdownMA.containsMouse ? "buttons/shutdown/button_2.png" : "buttons/shutdown/button_0.png")

                    MouseArea {
                        id: shutdownMA
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: root.powerOffRequested()
                    }
                }
                Text {
                    text: "Выключение";
                    font.pixelSize: 11;
                    font.family: root.fontFamily;
                    font.bold: true;
                    color: "#FFFFFF";
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            // 3. Кнопка: Перезагрузка
            Column {
                spacing: 8
                Image {
                    width: 32; height: 32
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: rebootMA.pressed
                    ? "buttons/shutdown/button_7.png"
                    : (rebootMA.containsMouse ? "buttons/shutdown/button_8.png" : "buttons/shutdown/button_6.png")

                    MouseArea {
                        id: rebootMA
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.rebootRequested()
                    }
                }
                Text {
                    text: "Перезагрузка";
                    font.pixelSize: 11;
                    font.family: root.fontFamily;
                    color: "#FFFFFF";
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }

        // НИЖНЯЯ ПАНЕЛЬ: КНОПКА ОТМЕНА (Белая с закругленными углами в стиле Луна)
        Rectangle {
            width: 78
            height: 22
            color: cancelMA.pressed ? "#E2E2DD" : "#FFFFFF" // Легкое потемнение при клике
            border.color: cancelMA.containsMouse ? "#0054E3" : "#7F9DB9" // Синяя рамка при наведении
            border.width: 1
            radius: 3 // В Windows XP кнопки имели небольшое скругление
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.margins: 14

            Text {
                text: "Отмена"
                anchors.centerIn: parent
                font.pixelSize: 11
                color: "#000000"
                font.family: root.fontFamily
            }

            MouseArea {
                id: cancelMA
                anchors.fill: parent
                hoverEnabled: true
                onClicked: root.visible = false
            }
        }
    }
}
