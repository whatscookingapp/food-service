import Fluent
import Vapor

final class Image: Model, Content {
    static let schema = "image"
    
    @ID(custom: "id", generatedBy: .random)
    var id: UUID?

    @Field(key: "bucket")
    var bucket: String?
    
    @Field(key: "key")
    var key: String?

    init() { }
}
