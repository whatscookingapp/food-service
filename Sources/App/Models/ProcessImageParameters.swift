import Foundation

struct ProcessImageParameters: Encodable {
    
    let bucket: String
    let key: String
    let edits: ImageEdits
}

struct ImageEdits: Encodable {
    
    let resize: ImageResize
}

struct ImageResize: Encodable {
    
    let width: Int
    let height: Int?
    let fit: ImageFit
}

enum ImageFit: String, Encodable {
    case cover
}
