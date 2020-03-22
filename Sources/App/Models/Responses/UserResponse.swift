import Vapor

struct UserResponse: Content {
    
    let id: UUID
    let name: String
    let image: ImageResponse?
    
    init(user: User) throws {
        self.id = try user.requireID()
        self.name = user.name
        self.image = nil
    }
}
