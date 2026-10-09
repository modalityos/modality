import QtQuick
import QtTest
import "../greeter/lib"
import "helpers"

// Seam 1: the Greeter driven through a fake Greeter backend.
TestCase {
    id: testCase

    name: "Greeter"
    width: 1280
    height: 800
    visible: true
    when: windowShown

    Component {
        id: backendComponent

        FakeBackend {}
    }

    Component {
        id: greeterComponent

        Greeter {
            width: testCase.width
            height: testCase.height
        }
    }

    function createGreeter(backendProperties) {
        const backend = createTemporaryObject(backendComponent, testCase, backendProperties ?? {});
        const greeter = createTemporaryObject(greeterComponent, testCase, { backend: backend });
        verify(greeter);
        return greeter;
    }

    function typeText(text) {
        for (const character of text)
            keyClick(character);
    }

    function test_correct_password_launches_the_session() {
        const greeter = createGreeter();
        const backend = greeter.backend;
        compare(greeter.state, "ready");

        typeText("secret");
        keyClick(Qt.Key_Return);
        compare(greeter.state, "checking");
        compare(backend.lastCall(), ["startAuthentication", "ian"]);

        backend.authPrompt("Password:", true);
        compare(backend.lastCall(), ["answer", "secret"]);

        backend.readyToLaunch();
        compare(greeter.state, "starting");
        tryVerify(() => backend.lastCall()[0] === "launch");
        compare(backend.lastCall(), ["launch", "org.modalityos.kwin"]);
    }
}
