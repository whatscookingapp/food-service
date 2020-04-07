import Vapor

struct ParticipantResponse: Content {
    
    let id: UUID
    let status: ParticipantStatus
    let user: UserResponse
    
    init(participant: Participant) throws {
        self.id = try participant.requireID()
        if let approved = participant.approved {
            self.status = approved ? .approved : .declined
        } else {
            self.status = .pending
        }
        self.user = try UserResponse(user: participant.user)
    }
}
