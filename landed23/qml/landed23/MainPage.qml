//import QtQuick 2.0
import QtQuick 1.1
//user interface abstraction layer so both harmattan and sailfish can be supported with the same code base
import org.flyingsheep.abstractui 1.0
//import com.nokia.meego 1.0
import QtMobility.location 1.2
import "settingsDB.js" as DB
import "landed.js" as LJS


AUIPageWithMenu {id: mainPage
    //tools: commonTools
    width: parent.width
    //width: 480
//    height: 828 -toolbarHeight
    orientationLock: AUIPageOrientation.LockPortrait

    //property int toolbarHeight: 0
    property int toolbarHeight: 110
    property int itemHeight: 100;
    property int headerHeight: itemHeight - 40;

    property color textColorActive
    property color textColorInactive
    property color labelColorActive
    property color labelColorInactive
    property int fontSize
    property bool groupSet: false;

    signal nextPage(string pageType, string smsType, string template_id, string msg_status)

    QtObject {
        id: privateVars
        property bool gpsAcquired: false
    }

    onStatusChanged: {
        console.log ("onStatusChanged: " + status);
        console.log ("privateVars.gpsAcquired: " + privateVars.gpsAcquired);
        if (status == AUIPageStatus.Active) {
            if (privateVars.gpsAcquired) {
                if (groupSet) {
                    console.log("user has changed group, so we will use the selected group")
                    templateButtons.setActiveGroup(thisGPSApp.getCurrentCoordinate());
                }
                else {
                    console.log("use the nearest group")
                    templateButtons.setNearestGroup(thisGPSApp.getCurrentCoordinate());
                }
            }
            console.log ("MainPage: turning GPS on ...");
            //thisGPSApp.onGPS();
            //thisGPSApp.activateGPS();
            gpsBackEnd.onGPS();

            compassApp.start();
        }
        else if (status == AUIPageStatus.Inactive) {
            //console.log ("turning GPS off ...")
            thisGPSApp.deactivateGPS();
            //thisGPSApp.offGPS();
            compassApp.stop();
        }
    }

    //////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////
    //GPS related functions
    //////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////

    function fakeGPSAquired() {
        //temporary function, used by testing to simulate gps aquired
        //for use when testing in building with no GPS signal
        privateVars.gpsAcquired = true;
    }

    function getLati() {
        //called from main.qml to pass lati to SMSPage
        return thisGPSApp.getLati()
    }

    function getLongi() {
        //called from main.qml to pass lati to SMSPage
        return thisGPSApp.getLongi()
    }

    function getAlti() {
        //called from main.qml to pass lati to SMSPage
        return thisGPSApp.getAlti();
    }

    GPSBackEnd {
        id: gpsBackEnd
        onSatsInUseChanged: {
            console.log("MainPage: onSatsInUseChanged: " + satsInUse);
        }
        onSatsInViewChanged: {
            console.log("MainPage: onSatsInViewChanged: " + satsInView);
            console.log("averagedCoordinate.latitude: " + averagedCoordinate.latitude)
        }
        onPositionChanged: {
            console.log("MainPage: PositionChanged Signal Received! outer");
            console.log("altitude is: " + position.coordinate.altitude)
            privateVars.gpsAcquired = true;
            gpsDisplay.displayOn();
        }
    }

    //////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////
    //GUI Elements
    //////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////

    //GUI: Header Bar at the top of the page
    Rectangle {
        id: landedHeader
        anchors {left: parent.left; leftMargin: 5; right: parent.right; rightMargin: 5; top: parent.top; topMargin: 5}
        height: 50
        color: (theme.inverted) ? "#333333" : "#006600"
        radius: 10
        Text {
            text: "Landed!!!"
            color: (theme.inverted) ? "white" : "white"
            font.pointSize: mainPage.fontSize
            font.weight: Font.DemiBold
            anchors.leftMargin: 10
            anchors.fill: parent
            verticalAlignment: Text.AlignVCenter
        }
    }

    //GUI: Displays GPS Data
    GPSDisplay{id: gpsDisplay
        //anchors.top: parent.top
        anchors.top: landedHeader.bottom
        anchors.topMargin: 5
        anchors.left: parent.left
        anchors.right: parent.right
        //color: parent.backgroundColor
        fontSize: parent.fontSize
        textColorActive: mainPage.textColorActive
        textColorInactive: mainPage.textColorInactive
        labelColorActive: mainPage.labelColorActive
        labelColorInactive: mainPage.labelColorInactive

        //bind properties to GPSBackEnd equivalents
//THINK: would it be better if the GPSDisplay element exposed a position property?
//then we would have much less bindings to make here!!!
//That would mean the GPSDisplay would need to import locations, at the moment it is dumb, and does not!
//Decide first if GPSBackEnd should be exposing position, or just coordinate element.
        latitude: gpsBackEnd.getFormatttedLatitude(gpsBackEnd.position.coordinate.latitude, coordFormatDMS)
        longitude: gpsBackEnd.getFormatttedLongitude(gpsBackEnd.position.coordinate.longitude, coordFormatDMS)
        altitude: gpsBackEnd.position.coordinate.altitude;
        speedValid: gpsBackEnd.position.speedValid;
        speed: gpsBackEnd.position.speed;
        horizontalAccuracyValid: gpsBackEnd.position.horizontalAccuracyValid;
        horizontalAccuracy: gpsBackEnd.position.horizontalAccuracy;
        verticalAccuracyValid: gpsBackEnd.position.verticalAccuracy;
        verticalAccuracy: gpsBackEnd.position.verticalAccuracy;
        satsInView: gpsBackEnd.satsInView;
        satsInUse: gpsBackEnd.satsInUse;
    }

    //GUI: Displays Compass Data
    CompassApp {
        id: compassApp
        anchors.top: gpsDisplay.bottom
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 10
        fontSize: parent.fontSize
        textColorActive: mainPage.textColorActive
        textColorInactive: mainPage.textColorInactive
        labelColorActive: mainPage.labelColorActive
        labelColorInactive: mainPage.labelColorInactive
    }

    //GUI: Text displayed in place of templateButtons when GPS not yet acquired
    Text {
        id: notAcquiredText;
        enabled: !templateButtons.enabled
        visible: !templateButtons.enabled
        anchors {left: parent.left; leftMargin: 10; right: parent.right; rightMargin: 10; top: compassApp.bottom; topMargin: 100}
        font.pointSize: parent.fontSize
        font.italic: true
        horizontalAlignment: Text.AlignHCenter
        color: mainPage.textColorInactive
        text: "GPS not yet acquired . . ."
    }

//TODO: I am not happy that we have 2 use 2 ways of triggering activation of buttons
// 1) templateButtons enabled bound to privateVars.gpsAcquired
// 2) page onStatusChanged event (for when we return to the page from another)

    //GUI: buttons for creating SMS, displayed when GPS is acquired
    TemplateButtons {
        id: templateButtons
        enabled: privateVars.gpsAcquired
        visible: privateVars.gpsAcquired
        fontSize: parent.fontSize
        itemHeight: parent.itemHeight
        headerHeight: parent.headerHeight
        //Commented out for Sailfish
        //backgroundColor: parent.backgroundColor
        arrowVisible: true
        textColor: parent.labelColorActive
        width: parent.width
        //anchors {left: parent.left; leftMargin: 10; right: parent.right; rightMargin: 10; top: compassText.bottom; topMargin: 15}
        anchors {left: parent.left; right: parent.right; top: compassApp.bottom; topMargin: 15}
        //onPopulated:
        onEnabledChanged: {
            console.log ("TemplateButtons: onEnabledChanged: " + enabled);
            if (enabled) {
                setNearestGroup(gpsBackEnd.position.coordinate);
                rumbleEffect.start();
            }
        }
        onDelegateClicked: {
            rumbleEffect.start();
            console.log("Default button chosen, for template_id: " + template_id);
            mainPage.nextPage("SMS", "Default", template_id, msg_status);
        }
        onHeaderClicked: {
            clear();
            mainPage.nextPage("Group", null, null, null);
        }

        function setHeaderText(group) {
            return group.name;
        }

        function setHeaderSubText(group, distance) {
            return "Lat: " + group.latitude + "; Lng: " + group.longitude + "; Dst: " + distance;
        }

        function set (group, distance) {
            templateButtons.headerText = setHeaderText(group);
            templateButtons.headerSubText = setHeaderSubText(group, distance);
            templateButtons.populate(group.id);
        }
        Coordinate {
            //used by function getDistance
            id: tempLocation
        }

        function getDistance(item, currentLocation) {
            tempLocation.latitude = item.latitude;
            tempLocation.longitude = item.longitude;
            return currentLocation.distanceTo(tempLocation);
        }

        function setActiveGroup(currentLocation) {
            var rs = DB.getActiveGroup();
            console.log ("No records found: " + rs.rows.length)
            var distance = formatDistance(getDistance(rs.rows.item(0), currentLocation));
            templateButtons.set(rs.rows.item(0), distance);
        }

        function setNearestGroup(currentLocation) {
            console.log ("current location latitude: " + currentLocation.latitude + " longitude: " + currentLocation.longitude)
            var rs = DB.getTemplateGroups();
            var distance;
            var nearestGroup = -1;
            var nearestGroupDistance = -1
            for(var i = 0; i < rs.rows.length; i++) {
                distance = getDistance(rs.rows.item(i), currentLocation);
                console.log ("distance: " + distance + " to " + rs.rows.item(i).name);
                if ( (distance < nearestGroupDistance) || (i == 0) ) {
                    nearestGroupDistance = distance;
                    nearestGroup = rs.rows.item(i);
                }
            }
            console.log ("nearest group is: " + nearestGroup.name + " " + nearestGroup.latitude);
            distance = formatDistance(nearestGroupDistance);
            templateButtons.set(nearestGroup, distance);
        }

        function formatDistance(distance) {
            return LJS.round((distance / 1000), 2) + " km";
        }
        RumbleEffect {id: rumbleEffect}
    }

    //GUI: Menu for various settings and test functions
    menuitems: [
        AUIMenuAction {
            text: qsTr("Fake GPS Aquired");
            onClicked: {
                mainPage.fakeGPSAquired();
            }
        },
        AUIMenuAction {
            text: (appWindow.fontSize >= appWindow.largeFonts) ? qsTr("Small Fonts" ) : qsTr("Large Fonts");
            onClicked: (appWindow.fontSize == appWindow.largeFonts) ? appWindow.fontSize = appWindow.smallFonts : appWindow.fontSize = appWindow.largeFonts;
        },
        AUIMenuAction {
            text: qsTr("Increase fontSize");
            onClicked: {
               appWindow.fontSize++;
               console.log ("fontSize is now: " + appWindow.fontSize + "; Operating System is: " + OSId)
            }
        },
        AUIMenuAction {
            text: qsTr("Decrease fontSize");
            onClicked: {
               appWindow.fontSize--;
               console.log ("fontSize is now: " + appWindow.fontSize + "; Operating System is: " + OSId)
            }
        },
        AUIMenuAction {
            text: qsTr("Toggle Theme");
            onClicked: {
               theme.inverted = !theme.inverted;
            }
        }
    ]

}