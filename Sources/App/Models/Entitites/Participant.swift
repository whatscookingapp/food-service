import Fluent
import Vapor

final class Participant: Model, Content {
    static let schema = "participant"
    
    @ID(custom: "id", generatedBy: .random)
    var id: UUID?

    @Parent(key: "user_id")
    var user: User
    
    @Parent(key: "food_id")
    var food: Food
    
    @Field(key: "approved")
    var approved: Bool?
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    init() { }

    init(userID: UUID, foodID: UUID) {
        self.$user.id = userID
        self.$food.id = foodID
    }
}
