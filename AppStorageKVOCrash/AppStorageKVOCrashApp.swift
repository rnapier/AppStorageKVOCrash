import SwiftUI

// Everything here is to log the creation/destruction of observations. It's not necessary to demonstrate the problem.

var shouldLog = false

@objc class DeallocSpy: NSObject {
    var string: String
    init(_ string: String) { self.string = string }
    deinit {
        print("***OBS-DIE*** \(string)")
    }
}

var spyKey = 0

extension NSObject {
    class func swizzle(_ original: Selector, with other: Selector) {
        let cls = Self.self
        let originalMethod = class_getInstanceMethod(cls, original)!
        let newMethod = class_getInstanceMethod(cls, other)!
        if (class_addMethod(cls, original, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
            class_replaceMethod(cls, other, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, newMethod)
        }
    }

}
extension UserDefaults {
    @objc func swizzle_addObserver(_ observer: NSObject,
                                   forKeyPath keyPath: String,
                                   options: NSKeyValueObservingOptions = [],
                                   context: UnsafeMutableRawPointer?) {
        let id = String(UInt(bitPattern: ObjectIdentifier(observer).hashValue), radix: 16)
        let string = "\(type(of: observer)) (\(id)): \(keyPath)"
        print("***OBS-ADD*** \(string)")
        swizzle_addObserver(observer, forKeyPath: keyPath, options: options, context: context)
        objc_setAssociatedObject(observer, &spyKey, DeallocSpy(string), .OBJC_ASSOCIATION_RETAIN)
    }

    @objc func swizzle_removeObserver(_ observer: NSObject, forKeyPath keyPath: String) {
        let id = String(UInt(bitPattern: ObjectIdentifier(observer).hashValue), radix: 16)
        print("***OBS-REM*** \(type(of: observer)) (\(id)): \(keyPath)")
        swizzle_removeObserver(observer, forKeyPath: keyPath)
    }
}

@main
struct AppStorageKVOCrashApp: App {
    init() {
        if shouldLog {
            // Demonstrate that observers are really created and destroyed
            UserDefaults.swizzle(#selector(UserDefaults.addObserver(_:forKeyPath:options:context:)),
                                 with: #selector(UserDefaults.swizzle_addObserver(_:forKeyPath:options:context:)))

            UserDefaults.swizzle(#selector(UserDefaults.removeObserver(_:forKeyPath:)),
                                 with: #selector(UserDefaults.swizzle_removeObserver(_:forKeyPath:)))
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
