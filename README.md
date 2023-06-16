#  AppStorageKVOCrash

This is a demo project for FB12348064, "AppStorage crashes if UserDefaults is modified on a background thread."

When using the AppStorage property wrapper, a KVO observation is attached to UserDefaults. If UserDefaults is
modified on a background thread at the same time that the AppStorage property is being deallocated, the 
application will crash. It does not matter whether the AppStorage property is the one being modified. If an
@AppStorage property is ever released, then any change to UserDefaults on a background thread can crash the
app, even though UserDefaults is documented to be thread-safe.

To demonstrate the problem, run this on device or simulator. In iOS versions up to 17b1, this crashes within
a few thousand iterations, generally within a few hundred.
