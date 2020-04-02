import Fluent
import SQLKit

struct FoodAddDocumentTrigger: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        guard let sqlDatabase = database as? SQLDatabase else { return database.eventLoop.makeSucceededFuture(()) }
        let createFuctionQuery = """
                    CREATE FUNCTION food_document_trigger() RETURNS trigger AS $$
                    begin
                      new.document :=
                         setweight(to_tsvector(cast(new.language AS regconfig), new.title), 'A') ||
                         setweight(to_tsvector(cast(new.language AS regconfig), COALESCE(new.description,'')), 'B');
                      return new;
                    end
                    $$ LANGUAGE plpgsql;
                    """
        let createTriggerQuery = """
                    CREATE TRIGGER upd_food_tsvector BEFORE INSERT OR UPDATE
                    ON "\(Food.schema)"
                    FOR EACH ROW EXECUTE PROCEDURE food_document_trigger();
                    """
        return sqlDatabase.raw(.init(createFuctionQuery)).run().flatMap { _ in
            sqlDatabase.raw(.init(createTriggerQuery)).run()
        }
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        guard let sqlDatabase = database as? SQLDatabase else { return database.eventLoop.makeSucceededFuture(()) }
        let queries = [sqlDatabase.raw("DROP TRIGGER IF EXISTS upd_food_tsvector ON \"\(Food.schema)\";").run(),
                       sqlDatabase.raw("DROP FUNCTION IF EXISTS food_document_trigger;").run()]
        return queries.flatten(on: database.eventLoop)
    }
}
