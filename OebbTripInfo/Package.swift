import PackageDescription

let package = Package(
    dependencies: [
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "1.7.4"),
    ],
    targets: [
        .target( name: "YourTarget", dependencies: ["SwiftSoup"]),
    ]
)
