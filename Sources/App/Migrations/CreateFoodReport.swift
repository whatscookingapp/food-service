import Fluent

struct CreateFoodReport: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(FoodReport.schema)
            .id()
            .field("item_id", .uuid, .references(Food.schema, "id"))
            .field("reporter_id", .uuid, .references(User.schema, "id"))
            .field("created_at", .datetime)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(FoodReport.schema).delete()
    }
}
