    import XCTest
    @testable import ios_mini_crash

    final class ios_mini_crashTests: XCTestCase {
        func testExample() {
//            XCTAssertEqual(ios_mini_crash().text, "Hello, World!")
            CrashManager.instance.installUncaughtExceptionHandler()
        }
    }
