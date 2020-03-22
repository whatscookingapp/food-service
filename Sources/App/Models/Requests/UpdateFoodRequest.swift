import Vapor

struct UpdateFoodRequest: Content {
    
    let title: String?
    let type: FoodType?
    let slots: Int?
    let bringContainer: Bool?
    let lat: Double?
    let lon: Double?
    let expires: Date?
}
