import AppKit

@MainActor
enum AppInstallation {
    static func openInstalledCopyIfRequested() async -> Bool {
        let files = FileManager.default
        let bundle = Bundle.main
        let source = bundle.bundleURL.resolvingSymlinksInPath()
        let applications = URL(fileURLWithPath: "/Applications", isDirectory: true)
        let personalApplications = files.homeDirectoryForCurrentUser.appendingPathComponent("Applications", isDirectory: true)
        let applicationFolders = [applications, personalApplications]
        guard source.pathExtension == "app",
              !applicationFolders.contains(where: {
                  source.pathComponents.starts(with: $0.resolvingSymlinksInPath().pathComponents)
              }) else { return false }

        let name = "Mochi Snap.app"
        let existing = applicationFolders.map { $0.appendingPathComponent(name, isDirectory: true) }
            .first { files.fileExists(atPath: $0.path) }
        let usePersonalFolder = !files.isWritableFile(atPath: applications.path)
        let directory = usePersonalFolder ? personalApplications : applications
        let destination: URL

        if let existing {
            let installed = Bundle(url: existing)
            let sameBuild = installed?.bundleIdentifier == bundle.bundleIdentifier
                && installed?.object(forInfoDictionaryKey: "CFBundleVersion") as? String
                    == bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String
            if sameBuild {
                guard confirm(title: String(localized: "install.existing.title"),
                              action: String(localized: "install.existing.open")) else { return false }
                destination = existing
            } else {
                if confirm(title: String(localized: "install.occupied.title"),
                           message: String(localized: "install.occupied.message"),
                           action: String(localized: "install.occupied.open")) {
                    NSWorkspace.shared.open(existing.deletingLastPathComponent())
                }
                return false
            }
        } else {
            guard confirm(title: String(localized: "install.title"),
                          message: usePersonalFolder ? String(localized: "install.personal.message")
                              : String(localized: "install.message"),
                          action: String(localized: "install.confirm")) else { return false }
            destination = directory.appendingPathComponent(name, isDirectory: true)
            do {
                try files.createDirectory(at: directory, withIntermediateDirectories: true)
                let staging = try files.url(for: .itemReplacementDirectory, in: .userDomainMask,
                                            appropriateFor: directory, create: true)
                defer { try? files.removeItem(at: staging) }
                let copy = staging.appendingPathComponent(name, isDirectory: true)
                try files.copyItem(at: source, to: copy)
                try files.moveItem(at: copy, to: destination)
            } catch {
                report(error)
                return false
            }
        }

        let installedURL = destination.resolvingSymlinksInPath()
        if let running = NSWorkspace.shared.runningApplications.first(where: {
            $0.bundleURL?.resolvingSymlinksInPath() == installedURL
        }) {
            running.activate()
            return true
        }

        let configuration = NSWorkspace.OpenConfiguration()
        configuration.createsNewApplicationInstance = true
        do {
            _ = try await NSWorkspace.shared.openApplication(at: destination, configuration: configuration)
            return true
        } catch {
            report(error)
            return false
        }
    }

    private static func confirm(title: String, message: String = "", action: String) -> Bool {
        let alert = NSAlert()
        alert.icon = NSApp.applicationIconImage
        alert.messageText = title
        alert.informativeText = message
        alert.addButton(withTitle: action)
        alert.addButton(withTitle: String(localized: "install.later")).keyEquivalent = "\u{1b}"
        NSApp.activate()
        return alert.runModal() == .alertFirstButtonReturn
    }

    private static func report(_ error: Error) {
        let alert = NSAlert(error: error)
        alert.messageText = String(localized: "install.error.title")
        alert.informativeText = error.localizedDescription
        NSApp.activate()
        alert.runModal()
    }
}
