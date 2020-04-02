import Fluent
import Vapor

final class Food: Model, Content {
    static let schema = "food"
    
    @ID(custom: "id", generatedBy: .random)
    var id: UUID?

    @Field(key: "title")
    var title: String
    
    @Field(key: "description")
    var description: String?
    
    @Parent(key: "creator_id")
    var creator: User
    
    @Enum(key: "type")
    var type: FoodType
    
    @Field(key: "image_id")
    var imageID: UUID?
    
    @Field(key: "slots")
    var slots: Int?
    
    @Field(key: "bring_container")
    var bringContainer: Bool
    
    @Field(key: "lat")
    var lat: Double?
    
    @Field(key: "lon")
    var lon: Double?
    
    @Field(key: "expires")
    var expires: Date?
    
    @Field(key: "show_distance")
    var showDistance: Bool
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    @Field(key: "document")
    var document: String?
    
    @Field(key: "language")
    var language: String
    
    init() { }

    init(createRequest: CreateFoodRequest, creatorID: UUID, language: String) {
        self.title = createRequest.title
        self.description = createRequest.description
        self.$creator.id = creatorID
        self.type = createRequest.type
        self.slots = createRequest.slots
        self.bringContainer = createRequest.bringContainer
        self.lat = createRequest.lat
        self.lon = createRequest.lon
        self.expires = createRequest.expires
        self.showDistance = createRequest.showDistance
        self.language = language
    }
}
