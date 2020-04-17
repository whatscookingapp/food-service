import Vapor

struct UpdateFoodRequest: Content {
    
    let title: String?
    let description: String?
    let type: FoodType?
    let slots: Int?
    let bringContainer: Bool?
    let lat: Double?
    let lon: Double?
    let showDistance: Bool?
    let expires: Date?
    let imageID: UUID?
}
