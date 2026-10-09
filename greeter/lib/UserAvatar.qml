import QtQuick
import Modality.Controls

// A user's Avatar: their AccountsService picture, else the built-in default avatar, also
// when the picture cannot be read.
Avatar {
    id: avatar

    // One entry of the Greeter backend's users.
    property var user: null
    property url fallback

    property bool pictureFailed: false

    name: user?.realName || user?.name || ""
    source: !pictureFailed && user?.avatar ? user.avatar : fallback

    function usePictureOrFallback() {
        if (status === Image.Error && user?.avatar)
            pictureFailed = true;
    }

    onUserChanged: pictureFailed = false
    // Later, not inside the status change: switching source changes status again.
    onStatusChanged: Qt.callLater(usePictureOrFallback)
}
