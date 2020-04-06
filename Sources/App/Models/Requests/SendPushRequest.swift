import Vapor

struct SendPushRequest: Content {
    
    let recipients: [UUID]
    let title: String
    let description: String
    let additionalData: [String: String]
}
