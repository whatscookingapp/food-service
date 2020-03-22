import Vapor

struct ImageResponse: Content {
    
    let thumbUrl: URL
    let mediumUrl: URL
    let largeUrl: URL
}
