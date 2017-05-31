// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "vaporMbao",
    targets: [
        Target(name: "App"),
        Target(name: "Run", dependencies:["App"]),
    ],
    dependencies: [
        .Package(url: "https://github.com/vapor/postgresql-provider.git", majorVersion: 2)
    ],
    exclude: [
        "Config",
        "Database",
        "Localization",
        "Public",
        "Resources",
    ]
)
