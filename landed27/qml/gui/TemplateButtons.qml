import QtQuick 2.0
//import QtQuick 1.1
import "../backend"
//import theme for button colours etc
import LandedTheme 1.0

Item {
    id: thisModel
    signal populated(string template_id);
    signal headerClicked();
    signal delegateClicked(string area_id, string template_id, string msg_status);

    //"outward" looking properties, should be bound by parent
    property int itemHeight: 60;
    property int marginWidth: 10;
    property int headerHeight: itemHeight;
    property string headerText
    property string headerSubText
    property bool arrowVisible: true
    property color textColor
    //Commented out for Sailfish
    //property color backgroundColor: "black"

    //inward looking, bound to inner objects.
    height: templateView.height

    //Commented out for Sailfish
    //color: backgroundColor

    property alias currentIndex: templateView.currentIndex;

    function populate(area_id) {
        templateModel.populate(area_id);
    }

    function clear() {
        headerText = "";
        templateModel.clear();
    }

    SMSTemplateListModel {
        id: templateModel
    }

    ListView {
        id: templateView
        anchors.left: parent.left
        anchors.right:parent.right
        anchors.leftMargin: marginWidth
        anchors.rightMargin: marginWidth
        model: templateModel
        delegate: templateDelegate
        header: templateHeader
        //stop dragging of the listview: we will need to change this if more buttons used
        interactive: false
        // Set the highlight delegate. Note we must also set highlightFollowsCurrentItem
        // to false so the highlight delegate can control how the highlight is moved.
        function resize(items){
            console.log("resizing");
            templateView.height = (items * itemHeight) + headerHeight;
        }
    }

    Component{
        id: templateHeader
        TemplateButtonsHeader {
            text: thisModel.headerText;
            subText: thisModel.headerSubText
            width: thisModel.width;
            //TODO: find a better way of calculating the height based on height of text + subText
            //height: thisModel.headerHeight * 1.666 //harmattan
            height: thisModel.headerHeight * 2
            //fontPixelSize: thisModel.fontPixelSize
            arrowVisible: thisModel.arrowVisible
            textColor: thisModel.textColor
            onClicked:{
                console.log("Template Header Clicked");
                thisModel.headerClicked();
            }
        }
    }

    Component {
        id: templateDelegate
        TemplateButtonsDelegate{
            width: thisModel.width - (marginWidth*2)
            height: thisModel.itemHeight
            text: button_label
            buttonColor: (msg_status == "Ok") ? LandedTheme.ButtonColorGreen : LandedTheme.ButtonColorRed;
            onClicked:{
                console.log("Template Delegate Clicked: area_id is: " + area_id + ", template_id is: " + template_id);
                templateView.currentIndex = index;
                thisModel.delegateClicked(area_id, template_id, msg_status);
            }
        }
    }
}
