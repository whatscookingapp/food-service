import Vapor

enum ParticipantStatus: String, Content {
    case approved
    case declined
    case unknown
}
