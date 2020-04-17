import Vapor

struct SendPushRequest: Content {
    
    let recipients: [UUID]
    let title: String?
    let description: String?
    let isContentAvailable: Bool?
    let additionalData: [String: String]
}
