import Fluent
import Vapor

struct FoodController: RouteCollection {
    
    private let foodRepository: FoodRepository
    private let participantRepository: ParticipantRepository
    
    init(foodRepository: FoodRepository,
         participantRepository: ParticipantRepository) {
        self.foodRepository = foodRepository
        self.participantRepository = participantRepository
    }
    
    func boot(routes: RoutesBuilder) throws {
        let foodRoute = routes.grouped("food")
        foodRoute.get("", use: fetch)
        foodRoute.post("", use: create)
        foodRoute.get(":id", use: details)
        foodRoute.patch(":id", use: update)
        foodRoute.delete(":id", use: delete)
        foodRoute.get(":id", "participants", use: getParticipants)
    }
}

private extension FoodController {
    
    func fetch(_ req: Request) throws -> EventLoopFuture<Page<FoodOverviewResponse>> {
        let language = req.retrievePreferredLanguages().preferredLanguage()
        let filters = try req.query.decode(FilterRequest.self)
        let sorting = try req.query.decode(SortRequest.self)
        let sortingType = sorting.sorting ?? .dateDesc
        let imageTransformer = try req.application.makeImageTransformer()
        return foodRepository.queryPaginated(filters: filters, sorting: sortingType, lat: sorting.lat, lon: sorting.lon, language: language, on: req).flatMapThrowing { page in
            try page.map { try FoodOverviewResponse(food: $0, lat: sorting.lat, lon: sorting.lon, imageTransformer: imageTransformer) }
        }
    }
    
    func create(_ req: Request) throws -> EventLoopFuture<CreateFoodResponse> {
        let language = req.retrievePreferredLanguages().preferredLanguage()
        let userID = try req.requireUserID()
        let createRequest = try req.content.decode(CreateFoodRequest.self)
        let food = Food(createRequest: createRequest, creatorID: userID, language: language)
        return foodRepository.save(food: food, on: req).flatMapThrowing {
            try CreateFoodResponse(id: $0.requireID())
        }
    }
    
    func details(_ req: Request) throws -> EventLoopFuture<FoodDetailResponse> {
        guard let id: UUID = req.parameters.get("id") else {
            throw Abort(.badRequest)
        }
        let userID = req.userID
        let imageTransformer = try req.application.makeImageTransformer()
        return foodRepository.findComplete(id: id, on: req).unwrap(or: Abort(.notFound)).flatMap { food -> EventLoopFuture<(Participant?, Food)> in
            if let userID = userID, food.$creator.id != userID {
                return self.participantRepository.find(userID: userID, foodID: id, on: req).and(value: food)
            } else {
                return req.eventLoop.makeSucceededFuture(nil).and(value: food)
            }
        }.flatMap { result -> EventLoopFuture<(([Participant], Participant?), Food)> in
            let (participant, food) = result
            if userID == food.$creator.id {
                return self.participantRepository.fetch(foodID: id, limit: 5, on: req).and(value: participant).and(value: food)
            } else {
                return req.eventLoop.makeSucceededFuture([]).and(value: participant).and(value: food)
            }
        }.flatMapThrowing { result in
            let ((participants, participant), food) = result
            return try FoodDetailResponse(food: food, userID: userID, lat: nil, lon: nil, imageTransformer: imageTransformer, participant: participant, participants: participants)
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
                return req.eventLoop.makeFailedFuture(Abort(.forbidden))
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
                return req.eventLoop.makeFailedFuture(Abort(.forbidden))
            }
            return self.foodRepository.delete(food: food, on: req).transform(to: .ok)
        }
    }
    
    func getParticipants(_ req: Request) throws -> EventLoopFuture<Page<ParticipantResponse>> {
        guard let id: UUID = req.parameters.get("id") else {
            throw Abort(.badRequest)
        }
        let imageTransformer = try req.application.makeImageTransformer()
        return participantRepository.all(foodID: id, on: req).flatMapThrowing { page in
            try page.map { try ParticipantResponse(participant: $0, imageTransformer: imageTransformer) }
        }
    }
}
