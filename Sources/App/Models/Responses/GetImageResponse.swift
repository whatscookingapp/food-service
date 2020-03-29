import Vapor

struct GetImageResponse: Content {
    
    let id: UUID
    let bucket: String
    let key: String
}
