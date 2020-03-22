import Vapor

extension Request {
    
    var userID: UUID? {
        guard let id = headers.firstValue(name: .init("X-User")) else { return nil }
        return UUID(uuidString: id)
    }
    
    func requireUserID() throws -> UUID {
        guard let id = userID else {
            throw Abort(.unauthorized)
        }
        return id
    }
}
