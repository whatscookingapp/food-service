import Fluent

struct FoodAddShowDistance: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Food.schema)
            .field("show_distance", .bool, .custom("DEFAULT FALSE"))
            .update()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Food.schema).deleteField("show_distance").delete()
    }
}
