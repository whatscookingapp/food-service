import Fluent

struct CreateParticipant: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Participant.schema)
            .id()
            .field("user_id", .uuid, .references(User.schema, "id", onDelete: .cascade))
            .field("food_id", .uuid, .references(Food.schema, "id", onDelete: .cascade))
            .field("approved", .bool)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Participant.schema).delete()
    }
}
