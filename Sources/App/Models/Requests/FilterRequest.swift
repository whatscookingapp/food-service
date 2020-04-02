import Vapor

struct FilterRequest: Content {
    
    let types: [FoodType]
    let slots: Int?
    let minimumDate: Date?
    let maximumDate: Date?
    let query: String?
}
