import QtQuick 2.0
//import QtQuick 1.1
import LandedTheme 1.0

Item {
    id: thisHeader
    signal clicked();
    signal editClicked();
    signal copyClicked();
    signal deleteClicked();

    property string text
    property string subText: "sub Text will be here"
    property bool arrowVisible: true
    property color textColor

    Text{
        id: mainText
        text: thisHeader.text
        font.pixelSize: LandedTheme.FontSizeLarge
        font.weight: Font.DemiBold
        //color: "black"
        color: thisHeader.textColor
        verticalAlignment: Text.AlignVCenter
    }
    Text{
        text: ">"
        font.pixelSize: LandedTheme.FontSizeLarge
        font.weight: Font.DemiBold
        color: "white"
        //verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignRight
        anchors.right: thisHeader.right
        anchors.rightMargin: 40 //sailfish
        width: 30
        visible: thisHeader.arrowVisible
    }
    Text{
        id: subText
        text: thisHeader.subText
        font.pixelSize: LandedTheme.FontSizeMedium
        font.weight: Font.DemiBold
        //color: "black"
        color: thisHeader.textColor
        //verticalAlignment: Text.AlignVCenter
        width: parent.width
        anchors.top: mainText.bottom
    }

    MouseArea{
        enabled: thisHeader.arrowVisible
        anchors.fill: thisHeader;
        onClicked:{
            console.log("Header Clicked")
            thisHeader.clicked();
        }
    }
}
