import Fluent

struct CreateFood: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.enum("food-type")
            .case("mealPickup")
            .case("mealJoin")
            .case("ingredientsSet")
            .case("ingredient")
            .create()
            .flatMap
            { type in
                database.schema(Food.schema)
                    .id()
                    .field("title", .string, .required)
                    .field("creator_id", .uuid, .references(User.schema, "id"))
                    .field("type", type, .required)
                    .field("image_id", .uuid, .references(Image.schema, "id"))
                    .field("slots", .int)
                    .field("bring_container", .bool)
                    .field("lat", .double)
                    .field("lon", .double)
                    .field("expires", .datetime)
                    .field("created_at", .datetime)
                    .field("updated_at", .datetime)
                    .create()
        }
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.enum("food-type").delete().flatMap {
            database.schema(Food.schema).delete()
        }
    }
}
