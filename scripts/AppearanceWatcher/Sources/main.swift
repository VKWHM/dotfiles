import AppKit
import Foundation

final class AppearanceObserverNotifier: NSObject {
    var ppid: UInt16
    init(ppid: UInt16) {
        self.ppid = ppid
        super.init()
    }
    
    func observe() {
      DistributedNotificationCenter.default.addObserver(
          forName: Notification.Name("AppleInterfaceThemeChangedNotification"),
          object: nil,
          queue: nil,
          using: self.changed(note: )
      )
    }

    func changed(note: Notification) {
        let style = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") ?? "Light"
        print("Appearance Changed: \(style)")
        // returns `[kinfo_proc]?`
        guard let procs = try? listChildren(of: ["zsh"]),
              !procs.isEmpty else {
            print("No zsh children found")
            return
        }
        let signal = style == "Dark" ? SIGUSR1 : SIGUSR2
        for proc in procs {
            proc.notify(signal: signal)
        }

    }
}


final class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
        let argv = CommandLine.arguments
        guard argv.count == 2, let ppid = UInt16(argv[1]) else {
            fputs("Usage: \(argv[0]) <ppid>", stderr)
            NSApp.terminate(nil)
            return
        }
        let observer = AppearanceObserverNotifier.init(ppid: ppid)
        observer.observe()
    }

}


let app = NSApplication.shared

let delegate = AppDelegate()
app.setActivationPolicy(.prohibited)
app.delegate = delegate

app.run()
