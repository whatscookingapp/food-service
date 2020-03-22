import Vapor

struct FoodResponse: Content {
    
    let id: UUID
    let title: String
    let creator: UserResponse
    let distance: Double
    let image: ImageResponse?
    let createdAt: Date?
    
    init(food: Food) throws {
        self.id = try food.requireID()
        self.title = food.title
        self.creator = try UserResponse(user: food.creator)
        self.distance = 0
        self.image = nil
        self.createdAt = food.createdAt
    }
}
