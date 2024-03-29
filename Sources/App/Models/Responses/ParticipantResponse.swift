import Vapor

struct ParticipantResponse: Content {
    
    let id: UUID
    let status: ParticipantStatus
    let foodID: UUID
    let user: UserResponse
    
    init(participant: Participant, imageTransformer: ImageTransformer) throws {
        self.id = try participant.requireID()
        self.foodID = participant.$food.id
        if let approved = participant.approved {
            self.status = approved ? .approved : .declined
        } else {
            self.status = .pending
        }
        self.user = try UserResponse(user: participant.user, imageTransformer: imageTransformer)
    }
}
