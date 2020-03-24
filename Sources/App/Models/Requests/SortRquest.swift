import Vapor

struct SortRequest: Content {
    
    let sorting: Sorting?
    let lat: Double?
    let lon: Double?
}
