import Foundation

extension Double {
    
    static let earthRadius: Double = 6371
    
    var degreesToRadians: Self { self * .pi / 180 }
    var radiansToDegrees: Self { self * 180 / .pi }
    
    static func distance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let theta = lon1 - lon2
        var dist = sin(lat1.degreesToRadians) * sin(lat2.degreesToRadians) + cos(lat1.degreesToRadians) * cos(lat2.degreesToRadians) * cos(theta.degreesToRadians)
        dist = acos(dist)
        dist = dist.radiansToDegrees
        dist = dist * 60 * 1.1515
        dist = dist * 1.609344
        
        return dist
    }
    
    static func boundingBox(lat: Double, lon: Double, radius: Double) -> ((Double, Double), (Double, Double)) {
        let minLat: Double = lat - (radius/earthRadius).radiansToDegrees
        let minLon: Double = lon - (radius/earthRadius/cos(lat.degreesToRadians)).radiansToDegrees
        let maxLat: Double = lat + (radius/earthRadius).radiansToDegrees
        let maxLon: Double = lon + (radius/earthRadius/cos(lat.degreesToRadians)).radiansToDegrees
        return ((minLat, minLon), (maxLat, maxLon))
    }
}
