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
                Label {
                    id: durum
                    Layout.fillWidth: true
                    Layout.minimumWidth: 80
                }
                Button {
                    id : okey
                    Layout.fillWidth: true
                    text: qsTr("Giriş")
                    onClicked: {
                        loading.running = true
                        loginPage()
                    }
                }
            }
        }
    }

    BusyIndicator {
        id: loading
        x: 105
        y: 60
        running: false
    }

    MessageDialog {
        id: loginNo
        title: "Hata"
        text: "Kullanıcı Adı veya Parola Hatalı."
        standardButtons: MessageDialog.Ok
        onAccepted: {
            userName.clear()
            password.clear()
            loading.running = false
        }
    }

    function loginPage() {
        var user = userName.text
        var pass = password.text

        if (user === "klasland" && pass === "klasland123") {
            durum.text = "Giriş başarılı..."
            loading.running = true
            var component = Qt.createComponent("main.qml", Component.Asynchronous, giris)
            component.statusChanged.connect(function() {
                if (component.status === Component.Ready) {
                    var window = component.createObject(giris)
                    if (window === null) {
                        console.log("Error creating object");
                    } else {
                        giris.hide()
                        window.show()
                    }
                    loading.running = false
                } else if (component.status === Component.Error) {
                    console.log("Error loading component:", component.errorString());
                    loading.running = false
                }
            });
        } else {
            loginNo.open()
        }
    }

}
