import Vapor

struct HeroResponse: Content {
    
    let title: String
    let image: ImageResponse?
    let destination: UUID
}
