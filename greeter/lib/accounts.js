.pragma library

// Users from busctl's JSON GetAll output for org.freedesktop.Accounts.User, one line per
// user. Lines that are not such JSON (errors, blanks) are skipped.
function parseUsers(text) {
    const users = [];
    for (const line of text.split("\n")) {
        let properties;
        try {
            properties = JSON.parse(line).data[0];
        } catch (e) {
            continue;
        }
        if (!properties?.UserName)
            continue;
        const icon = properties.IconFile?.data ?? "";
        users.push({
            name: properties.UserName.data,
            realName: properties.RealName?.data ?? "",
            avatar: icon.length > 0 ? `file://${icon}` : "",
            systemAccount: properties.SystemAccount?.data ?? false
        });
    }
    return users;
}
