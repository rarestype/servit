// swift-tools-version:6.2
import PackageDescription

let package: Package = .init(
    name: "servit-examples",
    platforms: [.macOS(.v15), .iOS(.v18), .tvOS(.v18), .visionOS(.v2), .watchOS(.v11)],
    products: [
        .executable(name: "Demo", targets: ["Demo"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ordo-one/dollup", from: "1.0.1"),
        .package(name: "servit", path: ".."),
    ],
    targets: [
        .executableTarget(
            name: "Demo",
            dependencies: [
                .product(name: "HTTPServer", package: "servit"),
            ],
            path: "Demo"
        ),
    ]
)

for target: Target in package.targets {
    switch target.type {
    case .binary: continue
    case .plugin: continue
    default: break
    }
    {
        var settings: [SwiftSetting] = $0 ?? []

        settings.append(.enableUpcomingFeature("ExistentialAny"))
        settings.append(.enableExperimentalFeature("StrictConcurrency"))

        settings.append(.treatWarning("ExistentialAny", as: .error))
        settings.append(.treatWarning("MutableGlobalVariable", as: .error))

        settings.append(.define("DEBUG", .when(configuration: .debug)))

        $0 = settings
    } (&target.swiftSettings)
}
