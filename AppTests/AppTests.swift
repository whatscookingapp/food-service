@testable import App
import XCTVapor

final class AppTests: XCTestCase {
    func testLogin() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)
        
        // Inject userClient somehow?
        
        try app.test(.POST, "auth/login") { res in
            // Assert userClient being invoked
        }
    }
}