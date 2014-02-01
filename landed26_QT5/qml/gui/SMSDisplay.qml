import QtQuick 2.0
//import QtQuick 1.1
//user interface abstraction layer so both harmattan and sailfish can be supported with the same code base
import org.flyingsheep.abstractui 1.0
//import com.nokia.meego 1.0
import LandedTheme 1.0

Rectangle{id: smsDisplay

    property bool smsSent: false
    property int defaultBottomMargin: 160
    property int fontSize: 16

    signal cancelled()
    signal phoneNrClicked()
    signal sendSMS(string phoneNumber, string text)

    function setState(msgState) {
        console.log("SMS Display: setState")
        if (msgState == "ActiveState") {
            phoneNrGroup.state = "stateSending";
        }
        else if (msgState == "FinishedState") {
            phoneNrGroup.state = "stateSent";
        }
        else if ((msgState == "Ready") && (phoneNrGroup.length() > 0) && (smsBody.length() > 0)) {
            phoneNrGroup.state = "stateReady";
        }
    }

    function setText(text) {
        smsBody.setText(text);
    }

    function setContact (contactName, contactPhone) {
        phoneNrGroup.setContact (contactName, contactPhone);
    }

    //This is variable height, shrinks when the visual keyboard opens
    SMSTextEdit { id: smsBody
        anchors.top: parent.top
        anchors.topMargin: 30
        anchors.bottom: phoneNrGroup.top
        anchors.bottomMargin: 0
        //anchors.bottomMargin: parent.defaultBottomMargin
        anchors.left: parent.left
        anchors.leftMargin: LandedTheme.MarginText
        anchors.right: parent.right
        anchors.rightMargin: LandedTheme.MarginText
        color: LandedTheme.BackgroundColorB
        //textColor set by state of phoneNrGroup below. I am not sure if I like this!!!¨
        fontFamily: "Arial"
        fontSize: smsDisplay.fontSize
        onKeysOpened: {
            //when the textArea visual keyboard is opened, hide the phoneNrGroup to increase
            //the screen area left for the text
            phoneNrGroup.state = "stateComposingText";
        }
        onKeysClosed: {
            phoneNrGroup.state = "stateAfterComposingText";
        }
    }

    Rectangle { id: phoneNrGroup
//TODO: do we need all these states? do they belong here? they also set SMS body properties!
        state: "stateReady";
        states: [
            State {
                name: "stateReady";
                PropertyChanges{ target: phoneNrGroup; visible: true }
                PropertyChanges{ target: phoneNrGroup; enabled: true }
                PropertyChanges{ target: sendButton; enabled: true }
                PropertyChanges{ target: sendButton; text: "Send" }
                //PropertyChanges{ target: phoneNrField; textColor: "black" } //harmattan
                PropertyChanges{ target: phoneNrField; textColor: "white" }
                PropertyChanges{ target: phoneNrField; text: phoneNrField.displayText() }
                //PropertyChanges{ target: phoneNrField; horizontalAlignment: Text.AlignRight }
                PropertyChanges{ target: phoneNrField; horizontalAlignment: Text.AlignLeft }
                PropertyChanges{ target: smsBody; textColor: "lightgreen" }
                StateChangeScript {
                         name: "myScript"
                         script: {
                             //make sure the vkb is not opened (we may be revisiting this screeen)
                             smsBody.closeSoftwareInputPanel();
                             phoneNrGroup.height = phoneNrGroup.restoreHeight();
                         }
                }
            },
            State {
                name: "stateComposingText";
                PropertyChanges{ target: smsBody; textColor: "lightgreen" }
                PropertyChanges{ target: phoneNrGroup; visible: false }
                PropertyChanges{ target: phoneNrGroup; enabled: false }
                PropertyChanges{ target: phoneNrGroup; height: 0 }
            },
            State {
                name: "stateAfterComposingText";
                PropertyChanges{ target: smsBody; textColor: "lightgreen" }
                PropertyChanges{ target: phoneNrGroup; visible: true }
                PropertyChanges{ target: phoneNrGroup; enabled: true }
                PropertyChanges{ target: phoneNrGroup; height: phoneNrGroup.restoreHeight(); }
                PropertyChanges{ target: sendButton; enabled: true }
                PropertyChanges{ target: sendButton; text: "Send" }
                PropertyChanges{ target: phoneNrField; textColor: "white" }
                PropertyChanges{ target: phoneNrField; text: phoneNrField.displayText() }
                PropertyChanges{ target: phoneNrField; horizontalAlignment: Text.AlignLeft }
                PropertyChanges{ target: smsBody; textColor: "lightgreen" }
            },
            State {
                name: "stateSending";
                PropertyChanges{ target: sendButton; enabled: false }
                PropertyChanges{ target: sendButton; text: "Sending..." }
                PropertyChanges{ target: phoneNrField; textColor: "darkgreen" }
                PropertyChanges{ target: phoneNrField; horizontalAlignment: Text.AlignLeft }
                PropertyChanges{ target: phoneNrField; text: "Sending to: " + phoneNrField.displayText() }
                PropertyChanges{ target: smsBody; textColor: "darkgreen" }
            },
            State {
                name: "stateSent";
                PropertyChanges{ target: sendButton; enabled: false }
                PropertyChanges{ target: sendButton; text: "" }
                PropertyChanges{ target: cancelButton; text: "Back" }
                PropertyChanges{ target: cancelButton; primaryColor: "#008000" }
                PropertyChanges{ target: phoneNrField; textColor: "grey" }
                PropertyChanges{ target: phoneNrField; horizontalAlignment: Text.AlignLeft }
                PropertyChanges{ target: phoneNrField; text: "Sent to: " + phoneNrField.displayText() }
                PropertyChanges{ target: smsBody; textColor: "grey" }
            }
        ]

        //we want the phoneNrGroup to only appear after the vkb has fully slid down.
        transitions: [
          Transition {
              from: "stateComposingText"; to: "stateAfterComposingText"
              PropertyAnimation { target: phoneNrGroup
                                  properties: "visible"; duration: 400 }
          }
        ]

        function restoreHeight(){
            console.log("restoreHeight: phoneNrField.height: " + phoneNrField.height)
            console.log("restoreHeight: sendButton.height: " + sendButton.height)
            return phoneNrField.height + sendButton.height + (3*5);
        }

        height: restoreHeight();
        anchors {left: parent.left; leftMargin: 10; right: parent.right; rightMargin: 10; bottom: parent.bottom; bottomMargin: 10}
        color: parent.color

        function length() {
            return phoneNrField.phoneNumber.length;
        }

        function setContact (contactName, contactPhone) {
            console.log ("Contact is : " + contactName +"; Phone is: " + contactPhone)
            setContactName (contactName);
            setPhoneNr(contactPhone);
        }

        function setPhoneNr (phoneNumber) {
            //phoneNrField.text = phoneNumber;
            phoneNrField.phoneNumber = phoneNumber;
        }

        function setContactName(name) {
            phoneNrField.contactName = name;
        }

        Rectangle{id: phoneNrField
            property alias text: label.text;
            property alias textColor: label.color
            property alias horizontalAlignment: label.horizontalAlignment
            property string phoneNumber
            property string contactName
            radius: 7;
            width: parent.width
            height: 120;
            anchors {top: parent.top; topMargin: 5}
            //color:  "lightyellow" harmattan
            color: LandedTheme.BackgroundColorC
            Text { id: label
                font.pointSize: smsDisplay.fontSize;
                font.family: "Arial";
                anchors.fill: parent;
                anchors.leftMargin: 10;
                anchors.rightMargin: 10;
                verticalAlignment: Text.AlignVCenter;
                //text: "this field is set in State above"
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    console.log("phoneNrField.MouseArea.onCicked");
                    phoneNrClicked();
                }
            }
            function displayText() {
                return phoneNrField.contactName + " on: " + "\n" + phoneNrField.phoneNumber;
            }
        }

        RumbleEffect {id: rumbleEffect}

        //Buttons have fixed height, and are anchored to the bottom of the page
        AUIButton {id: sendButton
            //height: 60 //harmattan
            height: 120 //sailfish
            //width: (parent.width - (3 * 10)) / 2 //harmattan
            width: (parent.width - (LandedTheme.MarginSmall)) / 2  //sailfish
            anchors{right: parent.right; bottom: parent.bottom; topMargin: 5;}
            primaryColor: "#008000" //"green"
            onClicked: {
                rumbleEffect.start();
                console.log("sendButton.onCicked");
                console.log("Sending text: " + smsBody.getText());
                console.log("to: " + phoneNrField.phoneNumber)
                smsDisplay.sendSMS(phoneNrField.phoneNumber, smsBody.getText());
                smsSent = true;
            }
        }

        AUIButton {id: cancelButton
            height: sendButton.height
            width: sendButton.width
            //anchors{left: parent.left; top: phoneNrField.bottom; topMargin: 10;};
            anchors{left: parent.left; bottom: parent.bottom; topMargin: 5;}
            text: "Cancel";
            primaryColor: "#808080" //"grey"
            onClicked: {
                rumbleEffect.start();
                console.log("SMSApp cancelButton.onCicked");
                phoneNrGroup.state ="stateNotReady";
                cancelled();
            }
        }

    }

}

