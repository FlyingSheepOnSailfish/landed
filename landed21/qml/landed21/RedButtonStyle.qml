import QtQuick 1.1
//user interface abstraction layer so both harmattan and sailfish can be supported with the same code base
import org.flyingsheep.abstractui 1.0
//import com.nokia.meego 1.0

AUIButtonStyle {
    background: "image://theme/meegotouch-button-negative"+__invertedString+"-background";
    pressedBackground: "image://theme/meegotouch-button-negative"+__invertedString+"-background-pressed";
    textColor: "Red"
}
