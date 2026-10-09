.pragma library

// Sessions from wayland-sessions desktop entries, printed as a record separator (U+001E)
// and the file's path, then its contents. An id seen twice keeps its first entry, so
// earlier folders win, as in XDG_DATA_DIRS. Hidden and NoDisplay entries are skipped; a
// Hidden one counts as deleted, so it also hides the same id in a later folder.
function parseSessions(text) {
    const sessions = [];
    const seen = new Set();
    for (const record of text.split("\u001e")) {
        const newline = record.indexOf("\n");
        if (newline < 0)
            continue;
        const path = record.slice(0, newline);
        const id = path.slice(path.lastIndexOf("/") + 1).replace(/\.desktop$/, "");
        const entry = parseEntry(record.slice(newline + 1));
        if (seen.has(id))
            continue;
        if (entry.Hidden === "true") {
            seen.add(id);
            continue;
        }
        if (!entry.Exec || entry.NoDisplay === "true")
            continue;
        seen.add(id);
        sessions.push({
            id: id,
            name: entry.Name ?? id,
            command: splitExec(entry.Exec),
            desktopNames: (entry.DesktopNames ?? "").split(";").filter(name => name.length > 0)
        });
    }
    return sessions;
}

// The keys of the [Desktop Entry] group; localised keys such as Name[de] are left out.
function parseEntry(text) {
    const keys = {};
    let inEntry = false;
    for (const line of text.split("\n")) {
        const trimmed = line.trim();
        if (trimmed.startsWith("[")) {
            inEntry = trimmed === "[Desktop Entry]";
            continue;
        }
        const equals = trimmed.indexOf("=");
        if (!inEntry || trimmed.startsWith("#") || equals < 0)
            continue;
        const key = trimmed.slice(0, equals).trim();
        if (!key.includes("["))
            keys[key] = trimmed.slice(equals + 1).trim();
    }
    return keys;
}

// An Exec value as an argument list: double quotes group, backslash escapes inside them,
// and field codes such as %U are dropped (a Session takes no files).
function splitExec(exec) {
    const args = [];
    let current = "";
    let quoted = false;
    let started = false;
    for (let i = 0; i < exec.length; i++) {
        const character = exec[i];
        if (quoted && character === "\\" && i + 1 < exec.length) {
            current += exec[++i];
        } else if (character === "\"") {
            quoted = !quoted;
            started = true;
        } else if (!quoted && /\s/.test(character)) {
            if (started)
                args.push(current);
            current = "";
            started = false;
        } else {
            current += character;
            started = true;
        }
    }
    if (started)
        args.push(current);
    return args.filter(arg => !/^%[a-zA-Z]$/.test(arg)).map(arg => arg.replace(/%%/g, "%"));
}
