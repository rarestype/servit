import HTTP
import HTTPServer
import MD5
import Multiparts
import NIOHPACK
import NIOHTTP1

extension HTTP.ServerRequest.Headers {
    @inlinable public subscript(header: String) -> [String] {
        switch self {
        case .http1_1(let self): self[header]
        case .http2(let self): self[header]
        }
    }
}
extension HTTP.ServerRequest.Headers {
    public var contentType: ContentType? {
        guard
        let contentType: String = self["content-type"].first,
        let contentType: ContentType = .init(contentType) else {
            return nil
        }

        return contentType
    }

    public var etag: MD5? {
        .init(header: self["if-none-match"])
    }

    public var host: String? {
        switch self {
        case .http1_1(let self):
            return self["host"].last

        case .http2(let self):
            return self[":authority"].last.map {
                if  let colon: String.Index = $0.lastIndex(of: ":") {
                    return String.init($0[..<colon])
                } else {
                    return $0
                }
            }
        }
    }
}
