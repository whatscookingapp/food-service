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
        participantRoute.post("", use: addParticipant)
        participantRoute.delete(":id", use: deleteParticipant)
        participantRoute.post(":id", "accept", use: acceptParticipant)
        participantRoute.post(":id", "decline", use: declineParticipant)
    }
}

private extension ParticipantController {
    
    func addParticipant(_ req: Request) throws -> EventLoopFuture<AddParticipantResponse> {
        let userID = try req.requireUserID()
        let addRequest = try req.content.decode(AddParticipantRequest.self)
        return foodRepository.find(id: addRequest.id, on: req).unwrap(or: Abort(.notFound)).flatMap { food -> EventLoopFuture<(Int, Food)> in
            guard food.$creator.id != userID else {
                return req.eventLoop.makeFailedFuture(Abort(.badRequest))
            }
            return self.participantRepository.findCount(userID: userID, foodID: addRequest.id, on: req).and(value: food)
        }.flatMap { value -> EventLoopFuture<Food> in
            let (count, food) = value
            guard count == 0 else {
                return req.eventLoop.makeFailedFuture(Abort(.badRequest))
            }
            let participant = Participant(userID: userID, foodID: addRequest.id)
            return self.participantRepository.save(participant: participant, on: req).map { _ in food }
        }.flatMapThrowing { food -> AddParticipantResponse in
            _ = req.application.pushClient.send(recipients: [food.$creator.id], title: "New join request", description: "There is a new join request for “\(food.title)”", additionalData: [:], on: req)
            return AddParticipantResponse(id: try food.requireID())
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
            participant.approved = true
            _ = req.application.pushClient.send(recipients: [food.$creator.id], title: "Join request approved", description: "Your request to join “\(food.title)” has been approved!", additionalData: [:], on: req)
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
            participant.approved = false
            _ = req.application.pushClient.send(recipients: [food.$creator.id], title: "Join request declined", description: "Your request to join “\(food.title)” has been declined!", additionalData: [:], on: req)
            return self.participantRepository.save(participant: participant, on: req).transform(to: .ok)
        }
    }
}
