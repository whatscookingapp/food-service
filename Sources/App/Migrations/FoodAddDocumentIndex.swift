import Fluent
import SQLKit

struct FoodAddDocumentIndex: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        guard let sqlDatabase = database as? SQLDatabase else { return database.eventLoop.makeSucceededFuture(()) }
        return sqlDatabase.raw("CREATE INDEX idx_food_fts_search ON \"\(Food.schema)\" USING gin(\"document\");").run()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        guard let sqlDatabase = database as? SQLDatabase else { return database.eventLoop.makeSucceededFuture(()) }
        return sqlDatabase.raw("DROP INDEX \"idx_food_fts_search\";").run()
    }
}
