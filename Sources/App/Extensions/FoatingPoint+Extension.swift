import Foundation

extension FloatingPoint {
    
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
}
