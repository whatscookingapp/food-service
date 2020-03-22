import Fluent
import Vapor

struct FoodController: RouteCollection {
    
    private let foodRepository: FoodRepository
    
    init(foodRepository: FoodRepository) {
        self.foodRepository = foodRepository
    }
    
    func boot(routes: RoutesBuilder) throws {
        let foodRoute = routes.grouped("food")
        foodRoute.get("", use: fetch)
        foodRoute.post("", use: create)
        foodRoute.put(":id", use: update)
    }
}

private extension FoodController {
    
    func fetch(_ req: Request) throws -> EventLoopFuture<Page<FoodResponse>> {
        let type: FoodType? = try? req.query.get(at: "type")
        let sorting: Sorting = (try? req.query.get(at: "sorting")) ?? .dateDesc
        let lat: Double? = try? req.query.get(at: "lat")
        let lon: Double? = try? req.query.get(at: "lon")
        return foodRepository.queryPaginated(type: type, sorting: sorting, lat: lat, lon: lon, on: req).flatMapThrowing { page in
            do {
                let food = try page.items.map { try FoodResponse(food: $0) }
                return Page(items: food, metadata: page.metadata)
            } catch {
                throw Abort(.internalServerError)
            }
        }
    }
    
    func create(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let userID = try req.requireUserID()
        let createRequest = try req.content.decode(CreateFoodRequest.self)
        let food = Food(createRequest: createRequest, creatorID: userID)
        return foodRepository.save(food: food, on: req).transform(to: .ok)
    }
    
    func update(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let id: UUID = req.parameters.get("id") else {
            throw Abort(.badRequest)
        }
        let userID = try req.requireUserID()
        let updateRequest = try req.content.decode(UpdateFoodRequest.self)
        return foodRepository.find(id: id, on: req).unwrap(or: Abort(.notFound)).flatMap { food in
            guard food.$creator.id == userID else {
                return req.eventLoop.makeFailedFuture(Abort(.unauthorized))
            }
            food.title = updateRequest.title ?? food.title
            food.slots = updateRequest.slots ?? food.slots
            food.bringContainer = updateRequest.bringContainer ?? food.bringContainer
            food.lat = updateRequest.lat ?? food.lat
            food.lon = updateRequest.lon ?? food.lon
            food.expires = updateRequest.expires ?? food.expires
            return self.foodRepository.save(food: food, on: req).transform(to: .ok)
        }
    }
}