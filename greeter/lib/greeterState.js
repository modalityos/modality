.pragma library

// The Greeter's state file: the last user to log in and each user's remembered Session,
// as JSON: { "lastUser": "katherine", "sessions": { "katherine": "org.modalityos.kwin" } }.

// Missing, corrupt or wrongly shaped text gives an empty state, so the Greeter falls back
// to its first user and the default Session.
function parseState(text) {
    let parsed;
    try {
        parsed = JSON.parse(text);
    } catch (e) {
        parsed = null;
    }
    const lastUser = typeof parsed?.lastUser === "string" ? parsed.lastUser : "";
    const sessions = {};
    const stored = parsed?.sessions;
    if (stored && typeof stored === "object" && !Array.isArray(stored)) {
        for (const user of Object.keys(stored)) {
            if (typeof stored[user] === "string")
                sessions[user] = stored[user];
        }
    }
    return { lastUser: lastUser, sessions: sessions };
}

// The state after user logs in to sessionId.
function withLogin(state, user, sessionId) {
    const sessions = Object.assign({}, state.sessions);
    sessions[user] = sessionId;
    return { lastUser: user, sessions: sessions };
}

function formatState(state) {
    return JSON.stringify(state) + "\n";
}
