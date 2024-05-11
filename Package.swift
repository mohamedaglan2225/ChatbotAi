// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ChatbotAi",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ChatbotAi",
            targets: ["ChatbotAi"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ChatbotAi",
            resources: [
                .copy("ChatFramework/View/ChatView.xib"),
                .copy("ChatFramework/Cells/SenderText/SenderTextCell.xib"),
                .copy("ChatFramework/Cells/ReceiverText/ReceiverTextCell.xib"),
                .copy("ChatFramework/Cells/RoomsCell/RoomsCell.xib"),
                .copy("ChatFramework/View/RecordView.xib"),
                .copy("ChatFramework/View/RoomsView.xib"),
            ])
        ,
        .testTarget(
            name: "ChatbotAiTests",
            dependencies: ["ChatbotAi"]),
    ]
)
