import Vapor
import Fluent

struct FoodDetailResponse: Content {
    
    let id: UUID
    let title: String
    let description: String?
    let creator: UserResponse
    let isCreator: Bool
    let distance: Double?
    let lat: Double?
    let lon: Double?
    let image: ImageResponse?
    let createdAt: Date?
    let participant: ParticipantResponse?
    let participants: [ParticipantResponse]
    
    init(food: Food, userID: UUID?, lat: Double?, lon: Double?, imageTransformer: ImageTransformer, participant: Participant?, participants: [Participant]) throws {
        self.id = try food.requireID()
        self.title = food.title
        self.description = food.description
        self.creator = try UserResponse(user: food.creator, imageTransformer: imageTransformer)
        let isCreator = food.$creator.id == userID
        self.isCreator = isCreator
        if let inputLat = lat, let inputLon = lon, let foodLat = food.lat, let foodLon = food.lon {
            self.distance = Double.distance(lat1: inputLat, lon1: inputLon, lat2: foodLat, lon2: foodLon)
        } else {
            self.distance = nil
        }
        if !food.showDistance || isCreator {
            self.lat = food.lat
            self.lon = food.lon
        } else {
            self.lat = nil
            self.lon = nil
        }
        let image = try food.joined(Image.self)
        if let bucket = image.bucket, let key = image.key {
            self.image = try imageTransformer.transform(bucket: bucket, key: key)
        } else {
            self.image = nil
        }
        self.createdAt = food.createdAt
        if let participant = participant {
            self.participant = try ParticipantResponse(participant: participant, imageTransformer: imageTransformer)
        } else {
            self.participant = nil
        }
        self.participants = try participants.map { try ParticipantResponse(participant: $0, imageTransformer: imageTransformer) }
    }
}
