import HTTPServer
import HTTP
import NIOCore
import NIOSSL

// 1. Define your new server logic
struct MyNewAppServer: HTTP.Server {
    func accept(request: HTTP.ServerRequest, method: HTTP.ServerMethod) async throws -> HTTP.ServerResponse {
        // Implement your new application's routing and response logic here
        switch request.uri.path {
        case ["api", "status"]:
            return .resource("MyNewAppServer: OK\n", status: 200)
        default:
            return .resource("MyNewAppServer: Not Found\n", status: 404)
        }
    }

    func reject(request: HTTP.ServerRequest) async throws -> HTTP.ServerResponse? {
        // Implement pre-flight checks for PUT requests (e.g., max payload sizes, auth)
        return nil
    }

    func log(event: HTTP.ServerEvent, ip origin: HTTP.ServerRequest.Origin?) {
        // Hook up your new app's logging system
        print("Event from \(String(describing: origin)): \(event)")
    }
}
// 2. Start the server with SSL
@main
struct App {
    static func main() async throws {
        // Set up your SSL Context for HTTPS using SwiftNIO SSL's correct types
        let privateKey: NIOSSLPrivateKey = try .init(
            file: "key.pem",
            format: .pem
        )
        let tlsConfig: TLSConfiguration = .makeServerConfiguration(
            certificateChain: try NIOSSLCertificate.fromPEMFile(
                "cert.pem"
            ).map {
                .certificate($0)
            },
            privateKey: .privateKey(privateKey)
        )
        let sslContext: NIOSSLContext = try .init(configuration: tlsConfig)
        let server: MyNewAppServer = .init()

        // The `serve` method lives in the extracted protocol extension
        try await server.serve(
            origin: .init(scheme: .https, authority: "api.myapp.com:443"), // <-- Fixed initializer
            host: "0.0.0.0",
            port: 8443,
            with: .local(sslContext), // <-- Argument label is `with:`, which fixes the contextual base error
            policy: nil
        )
    }
}
