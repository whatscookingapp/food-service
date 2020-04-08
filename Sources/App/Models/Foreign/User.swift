import Fluent
import Vapor

final class User: Model, Content {
    static let schema = "users"
    
    @ID(custom: "id", generatedBy: .random)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "bucket")
    var bucket: String?
    
    @Field(key: "key")
    var key: String?

    init() { }
}
