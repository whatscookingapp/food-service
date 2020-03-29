import Fluent
import Vapor

struct DiscoverController: RouteCollection {
    
    private let foodRepository: FoodRepository
    
    init(foodRepository: FoodRepository) {
        self.foodRepository = foodRepository
    }
    
    func boot(routes: RoutesBuilder) throws {
        let foodRoute = routes.grouped("discover")
        foodRoute.get("", use: fetch)
    }
}

private extension DiscoverController {
    
    func fetch(_ req: Request) throws -> EventLoopFuture<DiscoverResponse> {
        let imageTransformer = try req.application.makeImageTransformer()
        let laneQueries: [EventLoopFuture<LaneResponse>] = FoodType.allCases.map { type in
            return foodRepository.query(type: type, limit: 10, on: req).flatMapThrowing { items in
                let laneItems = try items.map { try FoodOverviewResponse(food: $0, lat: nil, lon: nil, imageTransformer: imageTransformer) }
                return LaneResponse(type: type, items: laneItems)
            }
        }
        return laneQueries.flatten(on: req.eventLoop).map { lanes in
            return DiscoverResponse(hero: nil, lanes: lanes)
        }
    }
}
