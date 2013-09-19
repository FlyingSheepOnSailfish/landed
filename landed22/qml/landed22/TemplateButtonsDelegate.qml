import QtQuick 1.1
//user interface abstraction layer so both harmattan and sailfish can be supported with the same code base
import org.flyingsheep.abstractui 1.0
//import com.nokia.meego 1.0

Item {
//Rectangle {

    signal clicked();
    property int fontSize: 24
    property string buttonColor
    property string text
//    color: "black";

    AUIButton {
        id: thisButton
        width: parent.width
        anchors.top: parent.top
        anchors.topMargin: 5
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
        text: parent.text

        primaryColor: parent.buttonColor
/*
Old Harmattan approach, using platformStyle:
However this has 2 problems:
a) Harmattan bug, meaning platformStyle cannot be changed by binding, needs to be explicitly changed
b) is not really Sailfish friendly (this needs to be verified).

So in the new approach we just change the primaryColor property of the button,
and delegate to the AUIButton how this is actually handled.

        property string buttonColor: parent.buttonColor
//Note due to a Qt bug, platformStyle cannot be changed via binding (as the the text above is)
//so we change it explicitly via a function
        //comment binding below to set explicitly
        //platformStyle: (parent.buttonColor == "red") ? redButton : greenButton
        onButtonColorChanged: {
            //Uncomment line below to be able to explicitly set platformStyle (rather than via binding)
            setPlatformStyle(buttonColor);
        }

        function setPlatformStyle(color) {
            //Note due to a Qt bug, platformStyle cannot be changed via binding (as the the text above is)
            //so we change it explicitly via a function

            console.log("Template Button Delegate: color is: " + color);
            if (color == "red") {
                thisButton.platformStyle = redButton;
            }
            else {
                thisButton.platformStyle = greenButton;
            }
        }

        RedButtonStyle {id: redButton}
        GreenButtonStyle {id: greenButton}
*/

        onTextChanged: console.log ("onTextChanged, text is: " + text)
        //onPlatformStyleChanged: console.log ("onPlatformStyleChanged, buttonColor is: " + buttonColor)
        onClicked: {
            console.log ("text is: " + text)
            console.log ("buttonColor: " + parent.buttonColor)
            parent.clicked();
        }


    }
}


