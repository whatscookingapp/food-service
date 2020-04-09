import Vapor
import FluentPostgresDriver

protocol ParticipantRepository {
    
    func findCount(userID: UUID, foodID: UUID, on req: Request) -> EventLoopFuture<Int>
    func find(userID: UUID, foodID: UUID, on req: Request) -> EventLoopFuture<Participant?>
    func find(userID: UUID, on req: Request) -> EventLoopFuture<Page<Participant>>
    func find(id: UUID, on req: Request) -> EventLoopFuture<Participant?>
    func findFull(id: UUID, on req: Request) -> EventLoopFuture<Participant?>
    func save(participant: Participant, on req: Request) -> EventLoopFuture<Participant>
    func delete(participant: Participant, on req: Request) -> EventLoopFuture<Void>
    func all(foodID: UUID, on req: Request) -> EventLoopFuture<Page<Participant>>
    func fetch(foodID: UUID, limit: Int, on req: Request) -> EventLoopFuture<[Participant]>
}

struct ParticipantRepositoryImpl: ParticipantRepository {
    
    func findCount(userID: UUID, foodID: UUID, on req: Request) -> EventLoopFuture<Int> {
        Participant.query(on: req.db).filter(\.$user.$id == userID).filter(\.$food.$id == foodID).count()
    }
    
    func find(userID: UUID, foodID: UUID, on req: Request) -> EventLoopFuture<Participant?> {
        Participant.query(on: req.db).filter(\.$user.$id == userID).filter(\.$food.$id == foodID).with(\.$user).first()
    }
    
    func find(userID: UUID, on req: Request) -> EventLoopFuture<Page<Participant>> {
        Participant.query(on: req.db)
            .filter(\.$user.$id == userID)
            .with(\.$food) {
                $0.with(\.$creator)
        }.paginate(for: req)
    }
    
    func find(id: UUID, on req: Request) -> EventLoopFuture<Participant?> {
        Participant.query(on: req.db).filter(\.$id == id).first()
    }
    
    func findFull(id: UUID, on req: Request) -> EventLoopFuture<Participant?> {
        Participant.query(on: req.db).filter(\.$id == id).with(\.$user).first()
    }
    
    func save(participant: Participant, on req: Request) -> EventLoopFuture<Participant> {
        participant.save(on: req.db).map { participant }
    }
    
    func delete(participant: Participant, on req: Request) -> EventLoopFuture<Void> {
        participant.delete(on: req.db)
    }
    
    func all(foodID: UUID, on req: Request) -> EventLoopFuture<Page<Participant>> {
        Participant.query(on: req.db).filter(\.$food.$id == foodID).with(\.$user).paginate(for: req)
    }
    
    func fetch(foodID: UUID, limit: Int, on req: Request) -> EventLoopFuture<[Participant]> {
        Participant.query(on: req.db).filter(\.$food.$id == foodID).with(\.$user).limit(limit).all()
    }
}
