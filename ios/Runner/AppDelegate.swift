import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    guard let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "PrivacyScreen")
    else { return }
    PrivacyScreen.shared.register(with: registrar.messenger())
  }
}

/// App-switcher cover for the app lock: while enabled, a solid view hides the
/// UI whenever the scene stops being active, so the system snapshot shown in
/// the switcher contains nothing. The Face ID / passcode sheet also
/// deactivates the scene, so the cover briefly replaces the lock screen behind
/// the system HUD during a prompt; accepted, nothing sensitive is behind it. Driven by Flutter over
/// `com.gatuno.app/privacy_screen`; observes scene notifications instead of
/// overriding FlutterSceneDelegate so Flutter's own lifecycle forwarding stays
/// untouched.
final class PrivacyScreen {
  static let shared = PrivacyScreen()

  private static let channelName = "com.gatuno.app/privacy_screen"
  private var isEnabled = false
  private var cover: UIView?
  private var observers: [NSObjectProtocol] = []

  private init() {}

  func register(with messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(
      name: PrivacyScreen.channelName, binaryMessenger: messenger)
    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "setEnabled" else {
        result(FlutterMethodNotImplemented)
        return
      }
      let arguments = call.arguments as? [String: Any]
      self?.setEnabled(arguments?["enabled"] as? Bool ?? false)
      result(nil)
    }
    observeScenes()
  }

  private func setEnabled(_ enabled: Bool) {
    isEnabled = enabled
    if !enabled { hide() }
  }

  private func observeScenes() {
    guard observers.isEmpty else { return }
    let center = NotificationCenter.default
    observers = [
      center.addObserver(
        forName: UIScene.willDeactivateNotification, object: nil, queue: .main
      ) { [weak self] notification in
        self?.show(in: notification.object as? UIWindowScene)
      },
      center.addObserver(
        forName: UIScene.didActivateNotification, object: nil, queue: .main
      ) { [weak self] _ in
        self?.hide()
      },
    ]
  }

  private func show(in scene: UIWindowScene?) {
    guard isEnabled, cover == nil,
      let window = scene?.windows.first(where: { $0.isKeyWindow }) ?? scene?.windows.first
    else { return }
    let view = UIView(frame: window.bounds)
    view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    // color/app-background (Dark #000212, Light #eeeeee), see DESIGN.md.
    view.backgroundColor = UIColor { traits in
      traits.userInterfaceStyle == .dark
        ? UIColor(red: 0, green: 2 / 255, blue: 18 / 255, alpha: 1)
        : UIColor(red: 238 / 255, green: 238 / 255, blue: 238 / 255, alpha: 1)
    }
    window.addSubview(view)
    cover = view
  }

  private func hide() {
    cover?.removeFromSuperview()
    cover = nil
  }
}
