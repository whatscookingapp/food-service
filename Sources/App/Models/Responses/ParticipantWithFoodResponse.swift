import Vapor

struct ParticipantWithFoodResponse: Content {
    
    let id: UUID
    let status: ParticipantStatus
    let food: FoodOverviewResponse
    
    init(participant: Participant, imageTransformer: ImageTransformer) throws {
        self.id = try participant.requireID()
        if let approved = participant.approved {
            self.status = approved ? .approved : .declined
        } else {
            self.status = .pending
        }
        self.food = try FoodOverviewResponse(food: participant.food, lat: nil, lon: nil, imageTransformer: imageTransformer)
    }
}
