import Fluent
import Vapor

struct ParticipantController: RouteCollection {
    
    private let foodRepository: FoodRepository
    private let participantRepository: ParticipantRepository
    
    init(foodRepository: FoodRepository,
         participantRepository: ParticipantRepository) {
        self.foodRepository = foodRepository
        self.participantRepository = participantRepository
    }
    
    func boot(routes: RoutesBuilder) throws {
        let participantRoute = routes.grouped("participant")
        participantRoute.get("", use: getParticipants)
        participantRoute.post("", use: addParticipant)
        participantRoute.delete(":id", use: deleteParticipant)
        participantRoute.post(":id", "accept", use: acceptParticipant)
        participantRoute.post(":id", "decline", use: declineParticipant)
    }
}

private extension ParticipantController {
    
    func getParticipants(_ req: Request) throws -> EventLoopFuture<Page<ParticipantWithFoodResponse>> {
        let userID = try req.requireUserID()
        let imageTransformer = try req.application.makeImageTransformer()
        return participantRepository.find(userID: userID, on: req).flatMapThrowing { page in
            try page.map { try ParticipantWithFoodResponse(participant: $0, imageTransformer: imageTransformer) }
        }
    }
    
    func addParticipant(_ req: Request) throws -> EventLoopFuture<ParticipantResponse> {
        let userID = try req.requireUserID()
        let addRequest = try req.content.decode(AddParticipantRequest.self)
        let imageTransformer = try req.application.makeImageTransformer()
        return foodRepository.find(id: addRequest.id, on: req).unwrap(or: Abort(.notFound)).flatMap { food -> EventLoopFuture<(Int, Food)> in
            guard food.$creator.id != userID else {
                return req.eventLoop.makeFailedFuture(Abort(.badRequest))
            }
            return self.participantRepository.findCount(userID: userID, foodID: addRequest.id, on: req).and(value: food)
        }.flatMap { value -> EventLoopFuture<(Participant, Food)> in
            let (count, food) = value
            guard count == 0 else {
                return req.eventLoop.makeFailedFuture(Abort(.badRequest))
            }
            let participant = Participant(userID: userID, foodID: addRequest.id)
            return self.participantRepository.save(participant: participant, on: req).and(value: food)
        }.flatMap { result in
            let (participant, food) = result
            guard let id = participant.id else {
                return req.eventLoop.makeFailedFuture(Abort(.internalServerError))
            }
            _ = req.application.pushClient.send(recipients: [food.$creator.id], title: "New join request", description: "There is a new join request for “\(food.title)”", additionalData: ["id": addRequest.id.uuidString], on: req)
            return self.participantRepository.findFull(id: id, on: req).unwrap(or: Abort(.notFound)).flatMapThrowing { try ParticipantResponse(participant: $0, imageTransformer: imageTransformer) }
        }
    }
    
    func deleteParticipant(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let id: UUID = req.parameters.get("id") else {
            throw Abort(.badRequest)
        }
        let userID = try req.requireUserID()
        return participantRepository.find(id: id, on: req).unwrap(or: Abort(.notFound)).flatMap { participant in
            guard participant.$user.id == userID else {
                return req.eventLoop.makeFailedFuture(Abort(.forbidden))
            }
            return self.participantRepository.delete(participant: participant, on: req).transform(to: .ok)
        }
    }
    
    func acceptParticipant(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let id: UUID = req.parameters.get("id") else {
            throw Abort(.badRequest)
        }
        let userID = try req.requireUserID()
        return participantRepository.find(id: id, on: req).unwrap(or: Abort(.notFound)).flatMap { participant in
            self.foodRepository.find(id: participant.$food.id, on: req).unwrap(or: Abort(.notFound)).and(value: participant)
        }.flatMap { result in
            let (food, participant) = result
            guard food.$creator.id == userID else {
                return req.eventLoop.makeFailedFuture(Abort(.forbidden))
            }
            guard let foodID = try? food.requireID() else {
                return req.eventLoop.makeFailedFuture(Abort(.internalServerError))
            }
            participant.approved = true
            _ = req.application.pushClient.send(recipients: [participant.$user.id], title: "Join request approved", description: "Your request to join “\(food.title)” has been approved!", additionalData: ["id": foodID.uuidString], on: req)
            return self.participantRepository.save(participant: participant, on: req).transform(to: .ok)
        }
    }
    
    func declineParticipant(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let id: UUID = req.parameters.get("id") else {
            throw Abort(.badRequest)
        }
        let userID = try req.requireUserID()
        return participantRepository.find(id: id, on: req).unwrap(or: Abort(.notFound)).flatMap { participant in
            self.foodRepository.find(id: participant.$food.id, on: req).unwrap(or: Abort(.notFound)).and(value: participant)
        }.flatMap { result in
            let (food, participant) = result
            guard food.$creator.id == userID else {
                return req.eventLoop.makeFailedFuture(Abort(.forbidden))
            }
            guard let foodID = try? food.requireID() else {
                return req.eventLoop.makeFailedFuture(Abort(.internalServerError))
            }
            participant.approved = false
            _ = req.application.pushClient.send(recipients: [participant.$user.id], title: "Join request declined", description: "Your request to join “\(food.title)” has been declined!", additionalData: ["id": foodID.uuidString], on: req)
            return self.participantRepository.save(participant: participant, on: req).transform(to: .ok)
        }
    }
}
