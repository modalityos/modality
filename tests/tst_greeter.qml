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

    function test_typing_goes_into_the_password_field_from_ready() {
        const greeter = createGreeter();
        typeText("se");
        compare(greeter.state, "typing");
        compare(findChild(greeter, "passwordField").text, "se");
    }

    function test_greeter_shows_the_last_user_name() {
        const greeter = createGreeter({
            users: [
                { name: "ada", realName: "Ada Lovelace", avatar: "", systemAccount: false },
                { name: "ian", realName: "Ian Gregson", avatar: "", systemAccount: false }
            ],
            lastUser: "ian"
        });
        compare(findChild(greeter, "userName").text, "Ian Gregson");
    }

    function test_user_without_a_real_name_shows_the_user_name() {
        const greeter = createGreeter({
            users: [{ name: "ian", realName: "", avatar: "", systemAccount: false }]
        });
        compare(findChild(greeter, "userName").text, "ian");
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
