import Flutter
import StoreKit
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
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "AppleBridge") {
      AppleBridge.register(with: registrar)
    }
  }
}

/// StoreKit 2 for the Flutter side (the one-time Pro purchase) and the keep-awake switch of the cooking mode.
/// Channel "kochmappe/apple":
///   products {ids} -> [{id, price, kind}]
///   purchase {id} -> "purchased" | "pending" | "cancelled"
///   entitlements -> [productId]
///   restore -> [productId]
///   keepAwake {on} -> nil (screen stays on while cooking)
final class AppleBridge: NSObject, FlutterPlugin {
  private var updates: Task<Void, Never>?

  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "kochmappe/apple", binaryMessenger: registrar.messenger())
    let bridge = AppleBridge()
    bridge.listenForTransactions()
    registrar.addMethodCallDelegate(bridge, channel: channel)
  }

  /// Finishes purchases made outside the app (e.g. Ask to Buy approved later).
  private func listenForTransactions() {
    updates = Task.detached {
      for await update in Transaction.updates {
        if case .verified(let t) = update { await t.finish() }
      }
    }
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any] ?? [:]
    switch call.method {
    case "products":
      let ids = args["ids"] as? [String] ?? []
      Task { await self.products(ids, result: result) }
    case "purchase":
      let id = args["id"] as? String ?? ""
      Task { await self.purchase(id, result: result) }
    case "entitlements":
      Task { await self.reply(result, await self.entitlements()) }
    case "restore":
      Task {
        do {
          try await AppStore.sync()
          await self.reply(result, await self.entitlements())
        } catch {
          await self.reply(result, FlutterError(code: "restore", message: "\(error)", details: nil))
        }
      }
    case "keepAwake":
      let on = args["on"] as? Bool ?? false
      DispatchQueue.main.async {
        UIApplication.shared.isIdleTimerDisabled = on
        result(nil)
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func reply(_ result: @escaping FlutterResult, _ value: Any?) async {
    await MainActor.run { result(value) }
  }

  // MARK: - StoreKit 2

  private func products(_ ids: [String], result: @escaping FlutterResult) async {
    do {
      let list = try await Product.products(for: ids)
      await reply(result, list.map { p -> [String: Any] in
        ["id": p.id, "price": p.displayPrice,
         "kind": p.type == .autoRenewable ? "subscription" : "lifetime"]
      })
    } catch {
      await reply(result, FlutterError(code: "products", message: "\(error)", details: nil))
    }
  }

  private func purchase(_ id: String, result: @escaping FlutterResult) async {
    do {
      guard let product = try await Product.products(for: [id]).first else {
        await reply(result, FlutterError(code: "purchase", message: "unknown product", details: nil))
        return
      }
      switch try await product.purchase() {
      case .success(let verification):
        if case .verified(let t) = verification {
          await t.finish()
          await reply(result, "purchased")
        } else {
          await reply(result, FlutterError(code: "purchase", message: "unverified", details: nil))
        }
      case .pending:
        await reply(result, "pending")
      case .userCancelled:
        await reply(result, "cancelled")
      @unknown default:
        await reply(result, "cancelled")
      }
    } catch {
      await reply(result, FlutterError(code: "purchase", message: "\(error)", details: nil))
    }
  }

  private func entitlements() async -> [String] {
    var ids: [String] = []
    for await entry in Transaction.currentEntitlements {
      if case .verified(let t) = entry, t.revocationDate == nil {
        ids.append(t.productID)
      }
    }
    return ids
  }
}
