# SwiftSafe
Thread synchronization made easy.

:question: Why?
----
Performance-sensitive classes need internal state synchronization, so that external accessors don't break the internal invariants and cause race conditions. Using GCD (Grand Central Dispatch) directly can confuse newcomers, because the API doesn't necessarily reflect the actual reason why it's being used. That's why wrapping it in a straighforward Swifty API can introduce a bit more clarity to your code. See examples below.

:watch: Concurrency modes supported
---------------------------
- EREW - **Exclusive Read, Exclusive Write**: The most common synchronization method, where only one thread can read or write your protected resource at one time. One big disadvantage is that it's prone to deadlocks.
- CREW - **Concurrent Read, Exclusive Write**: Less common, but IMO more powerful method, where multiple threads can read, but only one thread can write at one time. Reading and writing is automatically made exclusive, i.e. all reads enqueued before a write are executed first, then the single write is executed, then more reads can be executed (those enqueued after the write).

:octocat: Installation
----
Get `SwiftSafe` on CocoaPods, just add `pod 'SwiftSafe'` to your Podfile.

:mortar_board: Usage
-----
Let's say you're writing a thread-safe `NSData` cache. You'd like it to use CREW access to maximize performance.

```swift
class MyCache {
	private let storage: NSMutableDictionary = NSMutableDictionary()
	public func hit(key: String) -> NSData? {
		let found = self.storage[key]
		if let found = found {
			print("Hit for key \(key) -> \(found)")
		} else {
			print("Miss for key \(key)")
		}
		return found
	}
	public func update(key: String, value: NSData) {
		print("Updating \(key) -> \(value)")
		self.storage[key] = value
	}
}
```

This is the first implementation. It works, but when you start calling it from multiple threads at the same time, you'll encounter inconsistencies and race conditions - meaning you'll be getting different results with the same sequence of actions. In more complicated cases, you might even cause a runtime crash.

The way you fix it is obviously by protecting the internal `storage` (note: `NSDictionary` is not thread-safe). Again, to be most efficient, we want to allow any number of threads reading from the cache, but only one to update it (and ensure that nobody is reading from it at that time). You can achieve these guarantees with GCD, which is what `SwiftSafe` does. What this API brings to the table, however, is the simple and obvious naming.

Let's see how we can make our cache thread-safe in a couple lines of code.
```swift
import SwiftSafe

class MyCache {
	private let storage: NSMutableDictionary = NSMutableDictionary()
	private let safe: Safe = CREW()
	public func hit(key: String) -> NSData? {
		var found: NSData?
		safe.read {
			found = self.storage[key]
			if let found = found {
				print("Hit for key \(key) -> \(found)")
			} else {
				print("Miss for key \(key)")
			}
		}
		return found
	}
	public func update(key: String, value: NSData) {
		safe.write {
			print("Updating \(key) -> \(value)")
			self.storage[key] = value
		}
	}
}
```

That's it! Just import the library, create a `Safe` object which follows the concurrency mode you're trying to achieve (CREW in this case) and wrap your accesses to the shared resource in `read` and `write` calls. Note that `read` closures always **block** the caller thread, whereas `write` don't. If you ever have a call which both updates your resource and reads from it, make sure to split that functionality into the *writing* and *reading* part. This will make it much easier to reason about and parallelize.

:point_right: Bottom line
-------
Even though it might sound unnecessary to some, understandable and correct methods of synchronization will save you days of debugging and many headaches. :)

:v: License
-------
MIT

:alien: Author
------
Honza Dvorsky - http://honzadvorsky.com, [@czechboy0](http://twitter.com/czechboy0)