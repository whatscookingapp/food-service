import Fluent

struct FoodAddDescription: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Food.schema)
            .field("description", .string)
            .update()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Food.schema).deleteField("description").delete()
    }
}
