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
        foodRoute.patch(":id", use: update)
        foodRoute.delete(":id", use: delete)
    }
}

private extension FoodController {
    
    func fetch(_ req: Request) throws -> EventLoopFuture<Page<FoodOverviewResponse>> {
        let filters = try req.query.decode(FilterRequest.self)
        let sorting = try req.query.decode(SortRequest.self)
        let sortingType = sorting.sorting ?? .dateDesc
        let imageTransformer = try req.application.makeImageTransformer()
        return foodRepository.queryPaginated(type: filters.type, sorting: sortingType, lat: sorting.lat, lon: sorting.lon, on: req).flatMapThrowing { page in
            do {
                let food = try page.items.map { try FoodOverviewResponse(food: $0, lat: sorting.lat, lon: sorting.lon, imageTransformer: imageTransformer) }
                return Page(items: food, metadata: page.metadata)
            } catch {
                throw Abort(.internalServerError)
            }
        }
    }
    
    func create(_ req: Request) throws -> EventLoopFuture<CreateFoodResponse> {
        let userID = try req.requireUserID()
        let createRequest = try req.content.decode(CreateFoodRequest.self)
        let food = Food(createRequest: createRequest, creatorID: userID)
        return foodRepository.save(food: food, on: req).flatMapThrowing {
            try CreateFoodResponse(id: $0.requireID())
        }
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
            food.imageID = updateRequest.imageID ?? food.imageID
            return self.foodRepository.save(food: food, on: req).transform(to: .ok)
        }
    }
    
    func delete(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let id: UUID = req.parameters.get("id") else {
            throw Abort(.badRequest)
        }
        let userID = try req.requireUserID()
        return foodRepository.find(id: id, on: req).unwrap(or: Abort(.notFound)).flatMap { food in
            guard food.$creator.id == userID else {
                return req.eventLoop.makeFailedFuture(Abort(.unauthorized))
            }
            return self.foodRepository.delete(food: food, on: req).transform(to: .ok)
        }
    }
}
