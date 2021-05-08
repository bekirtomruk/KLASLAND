import QtQuick 2.14
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.1

ApplicationWindow {
    id: giris
    width: 250
    height: 160
    visible: true

    GridLayout {
        columns: 2
        rows: 2
        anchors.rightMargin: 10
        anchors.leftMargin: 10
        anchors.bottomMargin: 10
        anchors.topMargin: 10
        anchors.fill: parent

        ColumnLayout {
            width: 100
            height: 100

            Label {
                text: qsTr("Kullanıcı Adı")
                font.bold: true
                Layout.fillWidth: true
            }
            TextField {
                id: userName
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
                placeholderText: qsTr("Kullanıcı Adı")
                maximumLength: 12
                selectByMouse: true
                Keys.onReturnPressed: loginPage()
            }

            Label {
                text: qsTr("Parola")
                font.bold: true
                Layout.fillWidth: true
            }
            TextField {
                id: password
                echoMode: TextField.Password
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
                placeholderText: qsTr("Parola")
                maximumLength: 12
                selectByMouse: true
                Keys.onReturnPressed: loginPage()
            }

            RowLayout {
                Item {
                    width: 100
                }
                Button {
                    Layout.fillWidth: true
                    text: qsTr("Giriş")
                    onClicked: loginPage()
                }
            }
        }
    }

    MessageDialog {
        id: loginTrue
        title: "Hoşgeldiniz"
        text: "Sisteme Giriş Yapılıyor."
        standardButtons: MessageDialog.Ok
        onAccepted: {
            var component = Qt.createComponent("main.qml")
            var window = component.createObject(giris)
            giris.hide()
            window.show()
        }
    }
    MessageDialog {
        id: loginNo
        title: "Hata"
        text: "Kullanıcı Adı veya Parola Hatalı."
        standardButtons: MessageDialog.Ok
        onAccepted: {
            userName.clear()
            password.clear()
        }
    }

    function loginPage() {
        var user = userName.text
        var pass = password.text

        if (user === "klasland" && pass === "klasland123") {
            loginTrue.open()
        } else {
            loginNo.open()
        }
    }
}
