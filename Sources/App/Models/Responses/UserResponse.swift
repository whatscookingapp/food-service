import Vapor

struct UserResponse: Content {
    
    let id: UUID
    let name: String
    let image: ImageResponse?
    
    init(user: User, imageTransformer: ImageTransformer) throws {
        self.id = try user.requireID()
        self.name = user.name
        if let bucket = user.bucket, let key = user.key {
            self.image = try imageTransformer.transform(bucket: bucket, key: key)
        } else {
            self.image = nil
        }
    }
}
