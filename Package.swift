// swift-tools-version:6.2
import class Foundation.ProcessInfo
import PackageDescription
import CompilerPluginSupport

var AsyncChannelVendored: Bool {
    switch ProcessInfo.processInfo.environment["SWIFT_ASYNC_ALGORITHMS"] {
    case "true"?: false
    case "1"?: false
    default: true
    }
}

let package: Package = .init(
    name: "servit",
    platforms: [.macOS(.v15), .iOS(.v18), .tvOS(.v18), .visionOS(.v2), .watchOS(.v11)],
    products: [
        .library(name: "HTTP", targets: ["HTTP"]),
        .library(name: "HTTPClient", targets: ["HTTPClient"]),
        .library(name: "HTTPServer", targets: ["HTTPServer"]),
        .library(name: "Media", targets: ["Media"]),
        .library(name: "Multiparts", targets: ["Multiparts"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ordo-one/dollup", from: "1.0.0"),
        .package(url: "https://github.com/tayloraswift/swift-dom", from: "1.2.1"),
        .package(url: "https://github.com/tayloraswift/swift-grammar", from: "0.5.0"),
        .package(url: "https://github.com/tayloraswift/swift-hash", from: "0.7.1"),
        .package(url: "https://github.com/rarestype/swift-ip", from: "0.3.3"),
        .package(url: "https://github.com/tayloraswift/swift-json", from: "1.1.2"),
        .package(url: "https://github.com/tayloraswift/swift-png", from: "4.4.9"),
        .package(url: "https://github.com/tayloraswift/swift-ucf", from: "0.2.0"),
        .package(url: "https://github.com/tayloraswift/swift-unixtime", from: "0.2.0"),
        .package(url: "https://github.com/apple/swift-nio", from: "2.79.0"),
        .package(url: "https://github.com/apple/swift-nio-ssl", from: "2.27.0"),
        .package(url: "https://github.com/apple/swift-nio-http2", from: "1.33.0"),
        AsyncChannelVendored
            ? .package(url: "https://github.com/apple/swift-collections", from: "1.4.0")
            : .package(url: "https://github.com/apple/swift-async-algorithms", from: "1.1.3"),
    ],
    targets: [
        AsyncChannelVendored ? .target(
            name: "_AsyncChannel",
            dependencies: [
                .product(name: "OrderedCollections", package: "swift-collections"),
            ]
        ) : .target(
            name: "_AsyncChannel",
            dependencies: [
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
            ],
            path: "Sources/AsyncChannel"
        ),

        .target(
            name: "HTTP",
            dependencies: [
                .target(name: "Media"),
                .product(name: "ISO", package: "swift-unixtime"),
                .product(name: "MD5", package: "swift-hash"),
                .product(name: "NIOCore", package: "swift-nio"),
            ]
        ),

        .target(
            name: "HTTPClient",
            dependencies: [
                .target(name: "HTTP"),
                .target(name: "Media"),
                .product(name: "MD5", package: "swift-hash"),
                .product(name: "HTML", package: "swift-dom"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
                .product(name: "NIOHTTP2", package: "swift-nio-http2"),
                .product(name: "NIOSSL", package: "swift-nio-ssl"),
                .product(name: "TraceableErrors", package: "swift-grammar"),
            ]
        ),

        .target(
            name: "HTTPServer",
            dependencies: [
                .target(name: "_AsyncChannel"),
                .target(name: "HTTP"),

                .product(name: "Firewalls", package: "swift-ip"),
                .product(name: "IP", package: "swift-ip"),
                .product(name: "IP_NIOCore", package: "swift-ip"),
                .product(name: "HTML", package: "swift-dom"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
                .product(name: "NIOHTTP2", package: "swift-nio-http2"),
                .product(name: "NIOSSL", package: "swift-nio-ssl"),
                .product(name: "TraceableErrors", package: "swift-grammar"),
                .product(name: "URI", package: "swift-ucf"),
            ]
        ),

        .target(name: "Media"),

        .target(
            name: "Multiparts",
            dependencies: [
                .target(name: "Media"),
                .product(name: "Grammar", package: "swift-grammar"),
            ]
        ),

        .target(
            name: "SHA1_JSON",
            dependencies: [
                .product(name: "JSON", package: "swift-json"),
                .product(name: "SHA1", package: "swift-hash"),
            ]
        ),
    ]
)

for target: PackageDescription.Target in package.targets {
    if  target.name == "_AsyncChannel" {
        continue
    }

    {
        var settings: [PackageDescription.SwiftSetting] = $0 ?? []

        settings.append(.enableUpcomingFeature("ExistentialAny"))
        settings.append(.enableExperimentalFeature("StrictConcurrency"))

        settings.append(.treatWarning("ExistentialAny", as: .error))
        settings.append(.treatWarning("MutableGlobalVariable", as: .error))

        settings.append(.define("DEBUG", .when(configuration: .debug)))

        $0 = settings
    } (&target.swiftSettings)
}
