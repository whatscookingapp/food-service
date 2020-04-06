import Vapor
import AsyncHTTPClient

protocol PushClient {
    
    func send(recipients: [UUID], title: String, description: String, additionalData: [String: String], on request: Request) -> EventLoopFuture<HTTPStatus>
}

final class RemotePushClient: PushClient {
    
    private let host: String
    
    init(host: String) {
        self.host = host
    }
    
    func send(recipients: [UUID], title: String, description: String, additionalData: [String: String], on request: Request) -> EventLoopFuture<HTTPStatus> {
        let url = host + "/push"
        let requestBody = SendPushRequest(recipients: recipients, title: title, description: description, additionalData: additionalData)
        return request.client.post(.init(string: url), headers: request.headers) { request in
            try request.content.encode(requestBody)
        }.flatMapThrowing { response in
            request.logger.debug("Response: \(response)")
            guard response.status == .ok else {
                throw Abort(.internalServerError)
            }
            return .ok
        }
    }
}
