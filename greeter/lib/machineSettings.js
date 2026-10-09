.pragma library

// Machine settings for the Greeter: Defaults shipped under the install prefix, then Admin
// overrides from /etc/modalityos on top. A user's own settings never reach the Greeter.

// What the Greeter uses when neither file says otherwise.
const builtIn = {
    theme: "dark",
    clock24Hour: true,
    defaultSession: "org.modalityos.kwin",
    wallpaper: "silk",
    reduceTransparency: false
};

// Whether value is one the Greeter can use for key.
function isValid(key, value) {
    if (typeof value !== typeof builtIn[key])
        return false;
    if (key === "theme")
        return value === "dark" || value === "light";
    return typeof value !== "string" || value !== "";
}

// The settings a file's text sets: missing, corrupt or invalid entries set nothing.
function parseSettings(text) {
    let parsed;
    try {
        parsed = JSON.parse(text);
    } catch (e) {
        return {};
    }
    if (parsed === null || typeof parsed !== "object" || Array.isArray(parsed))
        return {};
    const settings = {};
    for (const key of Object.keys(builtIn)) {
        if (isValid(key, parsed[key]))
            settings[key] = parsed[key];
    }
    return settings;
}

// Each file's text in order of precedence, lowest first: later files win.
function resolveSettings(texts) {
    return Object.assign({}, builtIn, ...texts.map(parseSettings));
}
