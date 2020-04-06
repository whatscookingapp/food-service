import Fluent
import Vapor

func routes(_ app: Application) throws {
    
    app.get("status") { req -> HTTPStatus in
        return .ok
    }

    try app.register(collection: FoodController(foodRepository: FoodRepositoryImpl(), participantRepository: ParticipantRepositoryImpl()))
    try app.register(collection: DiscoverController(foodRepository: FoodRepositoryImpl()))
    try app.register(collection: ParticipantController(foodRepository: FoodRepositoryImpl(), participantRepository: ParticipantRepositoryImpl()))
}
