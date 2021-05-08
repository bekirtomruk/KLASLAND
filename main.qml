import QtQuick 2.14
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4 as QC14
// class ad belırledık
import QtQuick.LocalStorage 2.14
import QtQuick.Dialogs 1.1

ApplicationWindow {
    id: applicationWindow
    visible: true
    width: 380
    height: 675
    title: qsTr("Pazaryeri Kar/Zarar KLASLAND")

    Popup {
        //takvım popup
        id: calendarPopup
        parent: Overlay.overlay
        height: width
        closePolicy: Popup.CloseOnEscape
                     | Popup.CloseOnPressOutside //baska yere basılınca popup kapanması

        RowLayout {
            QC14.Calendar {
                //burda adı verılen tema uygulandı sadece
                id: calendar
                minimumDate: new Date(2020, 0, 1)
                maximumDate: new Date(2050, 0, 1)
                onClicked: calendarPopup.close()
            }
        }
    }

    ColumnLayout {
        anchors.rightMargin: 10 //sagdan margin
        anchors.leftMargin: 10 //soldan margin
        anchors.bottomMargin: 10 //alttan margin
        anchors.topMargin: 10 //ustten margin
        anchors.fill: parent //ortadan demirleme

        GridLayout {
            columns: 2
            rows: 2
            Layout.fillWidth: true

            TextField {
                id: tarih
                Layout.fillWidth: true
                text: Qt.formatDateTime(calendar.selectedDate, "dd/MM/yyyy")
                readOnly: true
                selectByMouse: true

                AnimatedImage {
                    width: 24
                    height: 24
                    source: "images/calendar-animation.gif"
                    anchors.rightMargin: 10
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        calendarPopup.x = 10
                        calendarPopup.y = 40
                        calendarPopup.open()
                    }
                }
            }

            TextField {
                id: faturaNo
                font.bold: true
                selectByMouse: true
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
                placeholderText: qsTr("Fatura Numarası")
                maximumLength: 13
                validator: RegExpValidator { regExp: /\d{13}/ } //sadece sayi girmek

                inputMethodHints: Qt.ImhDigitsOnly
            }
        }

        GridLayout {
            id: gridLayout
            width: 100
            height: 100

            ComboBox {
                id: pazarYeri
                font.bold: true
                model: ["PAZARYERİ", "Trendyol", "HepsiBurada", "N11", "GittiGidiyor", "Amazon", "AliExpress", "ÇiçekSepeti"]
                Layout.fillWidth: true
                onActivated: {
                    komisyonOraniniGuncelle()
                    kdvHesaplama()
                }
                Component.onCompleted: contentItem.horizontalAlignment
                                       = Text.AlignHCenter //metın ortaya hızalama
            }

            ComboBox {
                id: kategori
                font.bold: true
                model: ["KATEGORİ", "Kırlent Kılıfı", "Bijuteri", "Oyuncak", "T-Shirt"]
                Layout.fillWidth: true
                onActivated: {
                    komisyonOraniniGuncelle()
                    kdvHesaplama()
                }
                Component.onCompleted: contentItem.horizontalAlignment = Text.AlignHCenter
            }
        }

        TextField {
            id: komisyonOrani
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
            placeholderText: qsTr("Komisyon Oranı")
            maximumLength: 2
            validator: DoubleValidator {}
            enabled: true
            onTextEdited: kdvHesaplama()
            selectByMouse: true
            Label {

                text: qsTr("%")
                padding: 11
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignLeft
                anchors.fill: parent
            }
        }

        TextField {
            id: alisFiyati
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
            placeholderText: qsTr("Alış Fiyatı")
            maximumLength: 5
            validator: DoubleValidator {}
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onTextEdited: kdvHesaplama()
            selectByMouse: true
            Label {
                text: qsTr("TL")
                padding: 11
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignRight
                anchors.fill: parent
            }
        }

        TextField {
            id: satisFiyati
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
            placeholderText: qsTr("Satış Fiyatı")
            maximumLength: 5
            validator: DoubleValidator {}
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onTextEdited: kdvHesaplama()
            selectByMouse: true
            Label {
                text: qsTr("TL")
                padding: 11
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignRight
                anchors.fill: parent
            }
        }

        GridLayout {
            columns: 3
            rows: 3
            Layout.fillWidth: true

            Label {
                Layout.fillWidth: true
                text: qsTr("KDV ORANI")
                font.bold: true
            }

            RadioButton {
                id: sekizKdv
                Layout.fillWidth: true
                text: qsTr("8")
                checked: true
                onClicked: kdvHesaplama()
            }

            RadioButton {
                id: onsekizKdv
                Layout.fillWidth: true
                text: qsTr("18")
                onClicked: kdvHesaplama()
            }
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 2
            rows: 2
            TextField {
                id: kargoFiyati
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
                placeholderText: qsTr("Kargo Fiyatı")
                maximumLength: 5
                validator: DoubleValidator {}
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                enabled: !kargoAnahtari.checked
                onTextEdited: kdvHesaplama()
                selectByMouse: true
                Label {
                    text: qsTr("TL")
                    font.bold: true
                    padding: 11
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignRight
                    anchors.fill: parent
                }
            }
            ComboBox {
                id: kargoFirmasi
                font.bold: true
                model: ["KARGO FİRMASI", "PTT", "Yurtiçi", "Aras", "MNG", "KolayGelsin"]
                Layout.fillWidth: true
                Component.onCompleted: contentItem.horizontalAlignment = Text.AlignHCenter
            }
            Switch {
                id: kargoAnahtari
                text: qsTr("Alıcı Öder")
                width: 120
                font.bold: true
                Layout.fillWidth: true
                onClicked: {
                    kargoFiyati.text = 0
                    kargoFiyatiOzet.text = 0
                }
            }
            Item {
                Layout.fillWidth: true
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            height: 1
            color: "#c0c0c0"
        }

        ScrollView {
            leftPadding: 10
            rightPadding: 10
            topPadding: 2
            bottomPadding: 10
            Layout.fillHeight: true
            Layout.fillWidth: true
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: ScrollBar.AlwaysOn
            ColumnLayout {
                id: columnLayout
                width: applicationWindow.width - 40
                spacing: 10

                GridLayout {
                    columns: 2 //yatay satirin kac adet olucagi
                    rows: 5 //dikey satirin kac adet olucagi
                    Layout.fillWidth: true
                    Layout.rightMargin: 6

                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Özet Bilgiler")
                        font.bold: true
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Tarih")
                    }

                    Label {
                        Layout.fillWidth: true
                        text: qsTr(tarih.text)
                        horizontalAlignment: Text.AlignRight
                        font.bold: true
                    }

                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Fatura Numarası")
                    }

                    Label {
                        Layout.fillWidth: true
                        text: qsTr(faturaNo.text)
                        horizontalAlignment: Text.AlignRight
                        font.bold: true
                    }

                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Pazaryeri")
                    }

                    Label {
                        Layout.fillWidth: true
                        text: qsTr(pazarYeri.currentText)
                        horizontalAlignment: Text.AlignRight
                        font.bold: true
                    }

                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Kategori")
                    }

                    Label {
                        Layout.fillWidth: true
                        text: qsTr(kategori.currentText)
                        horizontalAlignment: Text.AlignRight
                        font.bold: true
                    }

                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Komisyon Oranı")
                    }

                    Label {
                        id: komisyonOraniOzet
                        Layout.fillWidth: true
                        text: qsTr(komisyonOrani.text)
                        horizontalAlignment: Text.AlignRight
                        font.bold: true
                    }
                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Alış Fiyatı")
                    }
                    Label {
                        Layout.fillWidth: true
                        text: qsTr(alisFiyati.text + " TL")
                        horizontalAlignment: Text.AlignRight
                        font.bold: true
                    }
                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Satış Fiyatı")
                    }
                    Label {
                        Layout.fillWidth: true
                        text: qsTr(satisFiyati.text + " TL")
                        horizontalAlignment: Text.AlignRight
                        font.bold: true
                    }
                    Label {
                        Layout.fillWidth: true
                        text: qsTr("KDV Oranı")
                    }
                    Label {
                        id : kdvOrani
                        Layout.fillWidth: true
                        text: sekizKdv.checked ? sekizKdv.text : onsekizKdv.text
                        horizontalAlignment: Text.AlignRight
                        font.bold: true
                    }

                    Label {
                        id: label
                        Layout.fillWidth: true
                        text: qsTr("Kargo Firması  + Fiyatı")
                    }
                    Label {
                        Layout.fillWidth: true
                        font.bold: true
                        text: qsTr(kargoFirmasi.currentText + " " + kargoFiyati.text + " TL")
                        horizontalAlignment: Text.AlignRight
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#c0c0c0"
                }

                GridLayout {
                    columns: 2
                    rows: 2
                    Layout.fillWidth: true
                    Layout.rightMargin: 6
                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Komisyon Bilgileri")
                        font.bold: true
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Komisyon  Tutarı")
                    }
                    Label {
                        id: komisyonFiyat
                        horizontalAlignment: Text.AlignRight
                        Layout.fillWidth: true
                        font.bold: true
                    }
                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Pazarlama Gideri")
                    }
                    Label {
                        id : pazarlamaFiyati
                        font.bold: true
                        horizontalAlignment: Text.AlignRight
                        Layout.fillWidth: true
                    }
                    Label {
                        Layout.fillWidth: true
                        text: qsTr("KDV Bilgileri")
                        font.bold: true
                    }
                    Item {
                        Layout.fillWidth: true
                    }

                    Label {
                        Layout.fillWidth: true
                        text: qsTr("  - Satış Kdv")
                    }

                    Label {
                        id: satisFiyatiOzet
                        Layout.fillWidth: true
                        text: qsTr("")
                        font.bold: true
                        horizontalAlignment: Text.AlignRight
                    }

                    Label {

                        Layout.fillWidth: true
                        text: qsTr("  - Alış Kdv")
                    }

                    Label {
                        id: alisFiyatiOzet
                        Layout.fillWidth: true
                        text: qsTr("")
                        font.bold: true
                        horizontalAlignment: Text.AlignRight
                    }

                    Label {
                        Layout.fillWidth: true
                        text: qsTr("  - Kargo Kdv")
                    }

                    Label {
                        id: kargoFiyatiOzet
                        Layout.fillWidth: true
                        text: qsTr("")
                        font.bold: true
                        horizontalAlignment: Text.AlignRight
                    }

                    Label {
                        Layout.fillWidth: true
                        text: qsTr("  - Komisyon Kdv")
                    }

                    Label {
                        id: komisyonFiyatOzet
                        Layout.fillWidth: true
                        text: qsTr("")
                        font.bold: true
                        horizontalAlignment: Text.AlignRight
                    }

                    Label {
                        Layout.fillWidth: true
                        text: qsTr("  - Pazarlama Kdv")
                        //opacity: pazarYeri.currentText === "N11"
                    }

                    Label {
                        id : pazarlamaFiyatiOzet
                        Layout.fillWidth: true
                        text: qsTr("")
                        font.bold: true
                        horizontalAlignment: Text.AlignRight
                        //opacity: pazarYeri.currentText === "N11"
                    }

                    Label {
                        text: qsTr("")
                        Layout.fillWidth: true
                    }

                    Label {
                        text: qsTr("_-_______")
                        horizontalAlignment: Text.AlignRight
                        Layout.fillWidth: true
                    }

                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Toplam KDV Tutarı")
                        font.bold: true
                    }

                    Label {
                        id: kdvHesaplamaOzet
                        Layout.fillWidth: true
                        font.bold: true
                        horizontalAlignment: Text.AlignRight
                    }

                    Label {
                        Layout.fillWidth: true
                        text: qsTr("KAR/ZARAR DURUMU")
                        font.bold: true
                    }

                    Label {
                        Layout.fillWidth: true
                        text: qsTr("")
                        horizontalAlignment: Text.AlignRight
                    }
                    Label {
                        Layout.fillWidth: true
                        text: qsTr("KAR/ZARAR DURUMU")
                    }
                    Label {
                        id : karzarar
                        Layout.fillWidth: true
                        text: (parseFloat(satisFiyati.text) - parseFloat(alisFiyati.text) - parseFloat(kargoFiyati.text) - parseFloat(komisyonFiyat.text) - parseFloat(pazarlamaFiyati.text) - Math.max(0, parseFloat(kdvHesaplamaOzet.text))).toFixed(2)
                        font.bold: true
                        horizontalAlignment: Text.AlignRight
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#c0c0c0"
        }

        MessageDialog {
            id: saveDialog
            title: "Emin misiniz?"
            text: "Kanka son kez soruyorum, emin misin?"
            standardButtons: MessageDialog.No | MessageDialog.Yes
            onYes: {
                var db = LocalStorage.openDatabaseSync(
                            "Faturalar", "1.0",
                            "Fatura gecmisi veritabani", 1000000)
                db.transaction(function (tx) {
                    tx.executeSql(
                                'CREATE TABLE IF NOT EXISTS FaturaOzet(ID INTEGER NOT NULL PRIMARY KEY, faturano INT, tarih TEXT, pazaryeri TEXT, kategori TEXT, komisyonOrani INT, kdvOrani INT, satisfiyati INT, alisfiyati INT, kargoFirmasi TEXT, kargoParasi INT, komisyonFiyat INT, pazarlamaFiyati INT, kdvHesaplamaOzet INT, karzarar INT)')
                    tx.executeSql(
                                'INSERT INTO FaturaOzet VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
                                [null, parseInt(
                                     faturaNo.text), tarih.text, pazarYeri.currentText, kategori.currentText, parseFloat(
                                     komisyonOrani.text), parseInt(kdvOrani.text), parseFloat(satisFiyati.text), parseFloat(alisFiyati.text), kargoFirmasi.currentText, parseFloat(kargoFiyati.text), parseFloat(komisyonFiyat.text), parseFloat(pazarlamaFiyati.text), parseFloat(kdvHesaplamaOzet.text), parseFloat(karzarar.text)])
                clearInterface()
                })
            }
        }

        MessageDialog {
            id: girdilerEksikDialog
            title: "Bilgiler Eksik"
            text: "Bro Napiyosun Sen Ya Adam Gibi Gir."
            standardButtons: MessageDialog.Ok
        }

        GridLayout {
            columns: 2
            rows: 2

            Button {
                Layout.fillWidth: true
                text: qsTr("Fatura Bulma")
                font.bold: true
                onClicked: {
                    var component = Qt.createComponent("giris.qml")
                    var window = component.createObject(applicationWindow)
                    window.applicationWindow = applicationWindow
                    window.show()
                    applicationWindow.hide()
                }
            }

            Button {
                Layout.fillWidth: true
                text: qsTr("İşlemi Tamamla")
                font.bold: true
                onClicked: {
                    if (girdilerTamam())
                        saveDialog.open()
                    else
                        girdilerEksikDialog.open()
                }

            }

        }
    }

    function clearInterface() {
        faturaNo.clear()
        pazarYeri.currentIndex = 0
        kategori.currentIndex = 0
        kargoFirmasi.currentIndex = 0
        alisFiyati.clear()
        satisFiyati.clear()
        kargoFiyati.clear()
        sekizKdv.checked = true
        komisyonOrani.clear()
        kargoAnahtari.checked = false
        kargoFiyati.clear()
    }

    function girdilerTamam() {
        if (faturaNo.text.length !== 13)
            return false
        if (pazarYeri.currentText === "PAZARYERİ")
            return false
        if (kategori.currentText === "KATEGORİ")
            return false
        if (kargoFirmasi.currentText === "KARGO FİRMASI")
            return false
        if (alisFiyati.length < 1)
            return false
        if (satisFiyati.length < 1)
            return false
        if (kargoFiyati.length < 1)
            return false
        return true
    }

    function komisyonOraniniGuncelle() {
        var komisyon = 0
        var py = pazarYeri.currentText.toLocaleLowerCase()
        var kg = kategori.currentText.toLocaleLowerCase()

        if (py === "trendyol") {
            if (kg === "kırlent kılıfı")
                komisyon = 24
            else if (kg === "bijuteri")
                komisyon = 22
            else if (kg === "oyuncak")
                komisyon = 15
            else if (kg === "t-shirt")
                komisyon = 20
        } else if (py === "hepsiburada") {
            if (kg === "kırlent kılıfı")
                komisyon = 25
            else if (kg === "bijuteri")
                komisyon = 27
            else if (kg === "oyuncak")
                komisyon = 15
            else if (kg === "t-shirt")
                komisyon = 28
        } else if (py === "n11") {
            if (kg === "kırlent kılıfı")
                komisyon = 15
            else if (kg === "bijuteri")
                komisyon = 20
            else if (kg === "oyuncak")
                komisyon = 15
            else if (kg === "t-shirt")
                komisyon = 20
        } else if (py === "gittigidiyor") {
            if (kg === "kırlent kılıfı")
                komisyon = 14
            else if (kg === "bijuteri")
                komisyon = 20
            else if (kg === "oyuncak")
                komisyon = 17
            else if (kg === "t-shirt")
                komisyon = 20
        }

        komisyonOrani.text = komisyon
        komisyonOraniOzet.text = "% " + komisyon
    }

    function kdvHesaplama() {
        var satisMatrah = parseFloat(satisFiyati.text)
        var alisMatrah = parseFloat(alisFiyati.text)
        var kargoMatrah = parseFloat(kargoFiyati.text)
        var komisyonMatrah = satisMatrah * (parseFloat(komisyonOrani.text) / 100.0)

        var pazarlamaGideri = parseFloat(satisFiyati.text) * 0.008
        var pazarlamaKdv = pazarlamaGideri - (pazarlamaGideri / (1 + (18 / 100.0)))

        var satisKdv = 0
        var alisKdv = 0
        var kargoKdv = 0
        var komisyonKdv = 0
        var toplamKdv = 0

        if (sekizKdv.checked === true) {
            satisKdv = satisMatrah - (satisMatrah / (1 + (8 / 100.0)))
            alisKdv = alisMatrah - (alisMatrah / (1 + (8 / 100.0)))
        } else {
            satisKdv = satisMatrah - (satisMatrah / (1 + (18 / 100.0)))
            alisKdv = alisMatrah - (alisMatrah / (1 + (18 / 100.0)))
        }
        kargoKdv = (kargoMatrah - (kargoMatrah / (1 + (18 / 100.0))))
        komisyonKdv = komisyonMatrah - (komisyonMatrah / (1 + (18 / 100.0)))
        if (pazarYeri.currentText === "N11") {
            pazarlamaFiyati.text = pazarlamaGideri.toFixed(2)
            pazarlamaFiyatiOzet.text = pazarlamaKdv.toFixed(2)
        } else{
            pazarlamaGideri = 0
            pazarlamaKdv = 0
            pazarlamaFiyati.text = pazarlamaGideri
            pazarlamaFiyatiOzet.text = pazarlamaKdv
        }

        toplamKdv = satisKdv - alisKdv - kargoKdv - komisyonKdv - pazarlamaKdv

        satisFiyatiOzet.text = satisKdv.toFixed(2)
        alisFiyatiOzet.text = alisKdv.toFixed(2)
        kargoFiyatiOzet.text = kargoKdv.toFixed(2)
        komisyonFiyat.text = komisyonMatrah.toFixed(2)
        komisyonFiyatOzet.text = komisyonKdv.toFixed(2)
        kdvHesaplamaOzet.text = toplamKdv.toFixed(2) + (toplamKdv < 0 ? " (KDV Yoktur)" : "")
    }
}
