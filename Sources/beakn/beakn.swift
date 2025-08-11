// The Swift Programming Language
// https://docs.swift.org/swift-book

import ArgumentParser
import Figlet
import FileMonitor
import Foundation
import PathKit

@main
struct beakn: AsyncParsableCommand {
    @Option(help: "The path to the file to watch")
    var path: Path

    func validate() throws {
        guard path.isFile else {
            throw ValidationError("(path) is not a file")
        }

        guard path.exists else {
            throw ValidationError("(path) does not exist")
        }
    }

    mutating func run() async throws {
        let monitor = try FileMonitor(directory: path.parent().url)

        for await event in monitor.stream {
            guard event.file.pathComponents == path.url.pathComponents else {
                continue
            }

            switch event {
            case .changed(_):
                print("Changed: (file)")
            case .added(_):
                print("Added (file)")
            case .deleted(_):
                print("Deleted file: (file)")
            }

        }
    }
}

extension FileChange {
    var file: URL {
        switch self {
        case .added(let file),
            .changed(let file),
            .deleted(let file):
            file.standardizedFileURL
        }
    }
}

extension Path: @retroactive ExpressibleByArgument {
    public init?(argument: String) {
        self.init(argument)
    }
}

// grep "workbench.colorTheme" ~/Library/Application\ Support/Code/User/settings.json