//Youareanidiot.exe for MacOS
//©Birdie Works '25. All rights reserved
//
//-- MacOS Credits --
//
//JBlueBird (https://github.com/JBlueBird) for MacOS port programming
//Youtube for the MP4 youare.mp4 file
//
//-- Original Creators/Main Credits --
//
//Jonty Lovell (https://https://youareanidiot.cc/) for creating youareanidiot.
//Andrew Regner (https://youareanidiot.org) for creating original domain
//ComputerVirusWatch for creating variants of the .exe in 2013
//"Cheap Radio Thrills" CD for music
//

import SwiftUI
import AVKit

@main
struct IdiotPrankApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var windowManager = WindowManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(windowManager)
                .onAppear {
                    Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
                        windowManager.openNewWindow()
                    }
                    // Start the random alert cycle
                    windowManager.scheduleRandomAlert()
                }
        }
        .windowStyle(HiddenTitleBarWindowStyle())
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApplication.shared.windows.first {
            window.delegate = self
            window.isMovableByWindowBackground = true
        }
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        showIdiotAlert()
        return false
    }
    
    private func showIdiotAlert() {
        let alert = NSAlert()
        alert.messageText = "You are an idiot!"
        alert.informativeText = ""
        alert.runModal()
    }
}

class WindowManager: NSObject, ObservableObject, NSWindowDelegate {
    private var windows: [NSWindow] = []

    private var randomAlertTimer: Timer?

    func openNewWindow() {
        let newWindow = NSWindow(
            contentRect: NSRect(x: 200, y: 200, width: 400, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        newWindow.isReleasedWhenClosed = false
        newWindow.title = "You are an idiot"
        newWindow.center()
        newWindow.setFrameAutosaveName("IdiotPrankWindow_\(windows.count)")
        newWindow.contentView = NSHostingView(rootView: ContentView())
        newWindow.delegate = self
        newWindow.isMovableByWindowBackground = true
        newWindow.makeKeyAndOrderFront(nil)

        windows.append(newWindow)
    }

    // Prevent closing any window and show alert
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        showIdiotAlert()
        return false
    }

    private func showIdiotAlert() {
        let alert = NSAlert()
        alert.messageText = "You are an idiot!"
        alert.informativeText = ""
        alert.runModal()
    }

    // Schedule the first random alert
    func scheduleRandomAlert() {
        scheduleNextRandomAlert()
    }

    private func scheduleNextRandomAlert() {
        // Random delay between 5 and 15 seconds
        let randomDelay = Double.random(in: 5...15)
        randomAlertTimer?.invalidate()
        randomAlertTimer = Timer.scheduledTimer(withTimeInterval: randomDelay, repeats: false) { [weak self] _ in
            self?.showRandomAlert()
        }
    }

    private func showRandomAlert() {
        // Pick a random window if any exist, else no alert
        guard let window = windows.randomElement() else {
            scheduleNextRandomAlert()
            return
        }
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "You are an idiot!"
            alert.informativeText = ""
            alert.beginSheetModal(for: window) { _ in
                // Schedule next alert after this one is dismissed
                self.scheduleNextRandomAlert()
            }
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var windowManager: WindowManager
    @StateObject private var mover = WindowMover()
    @State private var player: AVPlayer?

    @State private var videoSize: CGSize = .zero

    var body: some View {
        VStack {
            if let player = player {
                VideoPlayerView(player: player, onReady: { size in
                    videoSize = size
                    resizeWindow(to: size)
                })
                .frame(width: videoSize.width, height: videoSize.height)
            } else {
                Text("Loading video...")
                    .frame(width: 400, height: 300)
            }
        }
        .background(KeyCatcher {
            mover.toggleMoving()
        })
        .onAppear {
            if let url = Bundle.main.url(forResource: "youare", withExtension: "mp4") {
                player = AVPlayer(url: url)
                player?.play() // Autoplay!
            }
            mover.startMoving()
        }
        .onDisappear {
            mover.stopMoving()
        }
    }

    func resizeWindow(to size: CGSize) {
        DispatchQueue.main.async {
            if let window = NSApplication.shared.windows.first(where: { $0.contentView == NSApplication.shared.keyWindow?.contentView }) {
                var frame = window.frame
                let newSize = size

                let deltaWidth = newSize.width - frame.size.width
                let deltaHeight = newSize.height - frame.size.height

                frame.origin.x -= deltaWidth / 2
                frame.origin.y -= deltaHeight / 2
                frame.size = newSize

                window.setFrame(frame, display: true, animate: true)
            }
        }
    }
}

struct VideoPlayerView: NSViewRepresentable {
    let player: AVPlayer
    let onReady: (CGSize) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: .zero)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspect
        playerLayer.frame = view.bounds
        view.layer = playerLayer
        view.wantsLayer = true

        player.currentItem?.addObserver(context.coordinator,
                                        forKeyPath: "presentationSize",
                                        options: [.initial, .new],
                                        context: nil)

        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        if let playerLayer = nsView.layer as? AVPlayerLayer {
            playerLayer.player = player
            playerLayer.frame = nsView.bounds
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onReady: onReady)
    }

    class Coordinator: NSObject {
        let onReady: (CGSize) -> Void

        init(onReady: @escaping (CGSize) -> Void) {
            self.onReady = onReady
        }

        override func observeValue(forKeyPath keyPath: String?,
                                   of object: Any?,
                                   change: [NSKeyValueChangeKey : Any]?,
                                   context: UnsafeMutableRawPointer?) {
            if keyPath == "presentationSize",
               let playerItem = object as? AVPlayerItem {
                let size = playerItem.presentationSize
                if size != .zero {
                    DispatchQueue.main.async {
                        self.onReady(size)
                    }
                    playerItem.removeObserver(self, forKeyPath: "presentationSize")
                }
            }
        }
    }
}

struct KeyCatcher: NSViewRepresentable {
    var onSpacePressed: () -> Void

    func makeNSView(context: Context) -> CustomView {
        let view = CustomView()
        view.onSpacePressed = onSpacePressed
        DispatchQueue.main.async {
            view.window?.makeFirstResponder(view)
        }
        return view
    }

    func updateNSView(_ nsView: CustomView, context: Context) {}

    class CustomView: NSView {
        var onSpacePressed: (() -> Void)?

        override var acceptsFirstResponder: Bool { true }

        override func keyDown(with event: NSEvent) {
            if event.keyCode == 49 {
                onSpacePressed?()
            } else {
                super.keyDown(with: event)
            }
        }

        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            window?.makeFirstResponder(self)
        }
    }
}

class WindowMover: ObservableObject {
    private var timer: Timer?
    private weak var window: NSWindow? {
        NSApplication.shared.keyWindow
    }

    private var velocity = CGPoint(x: 300, y: 200)
    private var lastUpdate: Date?

    @Published private(set) var isMoving = true

    func startMoving() {
        lastUpdate = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { _ in
            self.updatePosition()
        }
    }

    func stopMoving() {
        timer?.invalidate()
        timer = nil
    }

    func toggleMoving() {
        isMoving.toggle()
    }

    private func updatePosition() {
        guard isMoving else { return }
        guard let window = window,
              let screen = window.screen else { return }

        let now = Date()
        guard let last = lastUpdate else {
            lastUpdate = now
            return
        }

        let deltaTime = now.timeIntervalSince(last)
        lastUpdate = now

        var frame = window.frame
        let screenFrame = screen.visibleFrame

        frame.origin.x += velocity.x * CGFloat(deltaTime)
        frame.origin.y += velocity.y * CGFloat(deltaTime)

        if frame.minX < screenFrame.minX {
            frame.origin.x = screenFrame.minX
            velocity.x = abs(velocity.x)
        }
        if frame.maxX > screenFrame.maxX {
            frame.origin.x = screenFrame.maxX - frame.width
            velocity.x = -abs(velocity.x)
        }

        if frame.minY < screenFrame.minY {
            frame.origin.y = screenFrame.minY
            velocity.y = abs(velocity.y)
        }
        if frame.maxY > screenFrame.maxY {
            frame.origin.y = screenFrame.maxY - frame.height
            velocity.y = -abs(velocity.y)
        }

        DispatchQueue.main.async {
            window.setFrame(frame, display: true)
        }
    }
}
