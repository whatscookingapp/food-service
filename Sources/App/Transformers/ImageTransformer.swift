import Vapor

struct ImageTransformer {
    
    private let imageHost: String
    
    init(imageHost: String) {
        self.imageHost = imageHost
    }
    
    func transform(bucket: String, key: String) throws -> ImageResponse {
        let thumbParameters = ProcessImageParameters(bucket: bucket, key: key, edits: .init(resize: .init(width: 100, height: 100, fit: .cover)))
        let mediumParameters = ProcessImageParameters(bucket: bucket, key: key, edits: .init(resize: .init(width: 500, height: nil, fit: .cover)))
        let largeParameters = ProcessImageParameters(bucket: bucket, key: key, edits: .init(resize: .init(width: 1000, height: nil, fit: .cover)))
        let encoder = JSONEncoder()
        let thumb = try encoder.encode(thumbParameters).base64EncodedString()
        let medium = try encoder.encode(mediumParameters).base64EncodedString()
        let large = try encoder.encode(largeParameters).base64EncodedString()
        guard let thumbUrl = URL(string: imageHost + "/" + thumb) else {
            throw Abort(.internalServerError)
        }
        guard let mediumUrl = URL(string: imageHost + "/" + medium) else {
            throw Abort(.internalServerError)
        }
        guard let largeUrl = URL(string: imageHost + "/" + large) else {
            throw Abort(.internalServerError)
        }
        return ImageResponse(thumbUrl: thumbUrl, mediumUrl: mediumUrl, largeUrl: largeUrl)
    }
}
