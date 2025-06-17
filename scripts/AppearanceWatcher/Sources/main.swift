import AppKit
import Foundation

final class AppearanceObserverNotifier: NSObject {
    
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
        guard let procs = try? listChildren(of: ["zsh", "nvim"]),
              !procs.isEmpty else {
            print("No zsh children found")
            return
        }
        let signal = style == "Dark" ? SIGUSR1 : SIGUSR2
        for proc in procs {
            proc.notify(signal: proc.cmd == "nvim" ? SIGUSR1 : signal)
        }

    }
}


final class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
        let observer = AppearanceObserverNotifier.init()
        observer.observe()
    }

}


let app = NSApplication.shared

let delegate = AppDelegate()
app.setActivationPolicy(.prohibited)
app.delegate = delegate

app.run()
