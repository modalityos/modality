import QtQuick
import QtTest
import Quickshell.Services.Greetd
import QuickshellStubs
import "../greeter"

// Seam 2: the real Greeter backend reads machine settings, Defaults under the install prefix
// and Admin overrides under /etc/modalityos, against the stubbed FileView.
TestCase {
    id: testCase

    name: "RealBackendSettings"

    readonly property string defaultsPath: "/opt/modalityos-dev/share/modalityos/settings.json"
    readonly property string adminOverridesPath: "/etc/modalityos/settings.json"

    Component {
        id: backendComponent

        RealBackend {
            prefix: "/opt/modalityos-dev"
        }
    }

    function init() {
        Greetd.reset();
        Files.reset();
    }

    function createBackend() {
        const backend = createTemporaryObject(backendComponent, testCase);
        verify(backend);
        return backend;
    }

    function test_defaults_set_the_machine_settings() {
        Files.write(testCase.defaultsPath, JSON.stringify({
            theme: "light",
            clock24Hour: false,
            defaultSession: "org.modalityos.hyprland",
            wallpaper: "dunes",
            reduceTransparency: true
        }));
        const backend = createBackend();
        compare(backend.theme, "light");
        compare(backend.clock24Hour, false);
        compare(backend.defaultSession, "org.modalityos.hyprland");
        compare(backend.wallpaper, "dunes");
        compare(backend.reduceTransparency, true);
    }

    function test_admin_overrides_beat_defaults_data() {
        return [
            {
                tag: "theme",
                key: "theme",
                defaults: "dark",
                adminOverride: "light"
            },
            {
                tag: "clock",
                key: "clock24Hour",
                defaults: true,
                adminOverride: false
            },
            {
                tag: "default Session",
                key: "defaultSession",
                defaults: "org.modalityos.kwin",
                adminOverride: "org.modalityos.hyprland"
            },
            {
                tag: "wallpaper",
                key: "wallpaper",
                defaults: "silk",
                adminOverride: "aurora"
            },
            {
                tag: "Reduce transparency",
                key: "reduceTransparency",
                defaults: false,
                adminOverride: true
            }
        ];
    }

    function test_admin_overrides_beat_defaults(data) {
        Files.write(testCase.defaultsPath, JSON.stringify({
            [data.key]: data.defaults
        }));
        Files.write(testCase.adminOverridesPath, JSON.stringify({
            [data.key]: data.adminOverride
        }));
        const backend = createBackend();
        compare(backend[data.key], data.adminOverride);
    }

    function test_admin_overrides_leave_the_other_defaults_in_place() {
        Files.write(testCase.defaultsPath, JSON.stringify({
            theme: "light",
            wallpaper: "dunes"
        }));
        Files.write(testCase.adminOverridesPath, JSON.stringify({
            wallpaper: "aurora"
        }));
        const backend = createBackend();
        compare(backend.theme, "light");
        compare(backend.wallpaper, "aurora");
    }

    function test_without_settings_files_the_greeter_is_dark_24_hour_kwin_on_silk() {
        const backend = createBackend();
        compare(backend.theme, "dark");
        compare(backend.clock24Hour, true);
        compare(backend.defaultSession, "org.modalityos.kwin");
        compare(backend.wallpaper, "silk");
        compare(backend.reduceTransparency, false);
    }

    function test_corrupt_admin_overrides_leave_the_defaults() {
        Files.write(testCase.defaultsPath, JSON.stringify({
            theme: "light"
        }));
        Files.write(testCase.adminOverridesPath, "{ theme: light");
        const backend = createBackend();
        compare(backend.theme, "light");
    }

    function test_unknown_or_wrongly_typed_settings_are_ignored_data() {
        return [
            {
                tag: "unknown theme",
                key: "theme",
                value: "sepia",
                expected: "dark"
            },
            {
                tag: "clock as text",
                key: "clock24Hour",
                value: "false",
                expected: true
            },
            {
                tag: "empty default Session",
                key: "defaultSession",
                value: "",
                expected: "org.modalityos.kwin"
            },
            {
                tag: "empty wallpaper",
                key: "wallpaper",
                value: "",
                expected: "silk"
            },
            {
                tag: "Reduce transparency as a number",
                key: "reduceTransparency",
                value: 1,
                expected: false
            }
        ];
    }

    function test_unknown_or_wrongly_typed_settings_are_ignored(data) {
        Files.write(testCase.adminOverridesPath, JSON.stringify({
            [data.key]: data.value
        }));
        const backend = createBackend();
        compare(backend[data.key], data.expected);
    }

    function test_admin_overrides_loaded_after_start_still_apply() {
        const backend = createBackend();
        compare(backend.theme, "dark");
        Files.write(testCase.adminOverridesPath, JSON.stringify({
            theme: "light"
        }));
        compare(backend.theme, "light");
    }
}
