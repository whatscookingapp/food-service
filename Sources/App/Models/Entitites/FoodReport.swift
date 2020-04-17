import Fluent
import Vapor

final class FoodReport: Model, Content {
    static let schema = "food_report"
    
    @ID(custom: "id", generatedBy: .random)
    var id: UUID?
    
    @Parent(key: "item_id")
    var item: Food
    
    @Parent(key: "reporter_id")
    var reporter: User
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    init() { }

    init(itemID: UUID, reporterID: UUID) {
        self.$item.id = itemID
        self.$reporter.id = reporterID
    }
}
