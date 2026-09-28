import XCTest
@testable import Mountlane

final class VolumeInfoTests: XCTestCase {
    func testReadOnlyVolumeUsesReadOnlyAccessKey() {
        let volume = makeVolume(isReadOnly: true, total: 100, available: 25)

        XCTAssertEqual(volume.accessModeKey, "access.readOnly")
    }

    func testWritableVolumeCalculatesUsedCapacity() throws {
        let volume = makeVolume(isReadOnly: false, total: 100, available: 25)

        XCTAssertEqual(volume.accessModeKey, "access.readWrite")
        XCTAssertEqual(try XCTUnwrap(volume.usedFraction), 0.75, accuracy: 0.0001)
    }

    func testVolumeWithoutCapacityHasNoUsageFraction() {
        XCTAssertNil(makeVolume(isReadOnly: false, total: nil, available: nil).usedFraction)
    }

    func testSortKeepsFoldersBeforeFiles() {
        let folder = FileItem(url: URL(fileURLWithPath: "/Folder"), name: "Folder", isDirectory: true, size: nil, modificationDate: nil)
        let file = FileItem(url: URL(fileURLWithPath: "/File.txt"), name: "File.txt", isDirectory: false, size: 12, modificationDate: nil)

        XCTAssertEqual(FileSortOrder.size.sorted([file, folder]).map(\.name), ["Folder", "File.txt"])
    }

    func testNTFSDetectionUsesFormatDescription() {
        XCTAssertTrue(makeVolume(isReadOnly: true, total: nil, available: nil, fileSystem: "Windows NTFS").isNTFS)
        XCTAssertFalse(makeVolume(isReadOnly: true, total: nil, available: nil, fileSystem: "exFAT").isNTFS)
    }

    func testNTFSRemountPlanOnlyAcceptsDiskIdentifiers() throws {
        let plan = try NTFSRemountPlan.make(deviceIdentifier: "disk4s2", providerPath: "/opt/homebrew/bin/ntfs-3g")

        XCTAssertEqual(plan.mountPoint, "/Volumes/Mountlane-disk4s2")
        XCTAssertTrue(plan.shellCommand.contains("/dev/disk4s2"))
        XCTAssertThrowsError(try NTFSRemountPlan.make(deviceIdentifier: "disk4; rm -rf /", providerPath: "/tmp/driver"))
    }

    func testCopyDestinationKeepsBothNames() {
        let source = URL(fileURLWithPath: "/origin/report.pdf")
        let manager = FileManager.default
        let temporary = manager.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? manager.removeItem(at: temporary) }
        try? manager.createDirectory(at: temporary, withIntermediateDirectories: true)
        manager.createFile(atPath: temporary.appendingPathComponent("report.pdf").path, contents: Data())

        XCTAssertEqual(CopyEngine.availableDestination(for: source, in: temporary).lastPathComponent, "report 2.pdf")
    }

    private func makeVolume(isReadOnly: Bool, total: Int64?, available: Int64?, fileSystem: String = "exFAT") -> VolumeInfo {
        VolumeInfo(
            id: "test-volume",
            url: URL(fileURLWithPath: "/Volumes/Test"),
            name: "Test",
            fileSystem: fileSystem,
            isReadOnly: isReadOnly,
            isRemovable: true,
            isEjectable: true,
            totalCapacity: total,
            availableCapacity: available
        )
    }
}
