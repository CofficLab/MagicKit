import XCTest
@testable import MagicCore

/// MagicDiffView 折叠功能测试
final class MagicDiffViewCollapsingTests: XCTestCase {
    
    /// 测试折叠块的创建
    func testCollapsibleBlockCreation() {
        let lines = [
            DiffLine(content: "line 1", type: .unchanged, oldLineNumber: 1, newLineNumber: 1),
            DiffLine(content: "line 2", type: .unchanged, oldLineNumber: 2, newLineNumber: 2),
            DiffLine(content: "line 3", type: .unchanged, oldLineNumber: 3, newLineNumber: 3)
        ]
        
        let block = CollapsibleBlock(
            lines: lines,
            isCollapsed: true,
            startLineNumber: 1,
            endLineNumber: 3
        )
        
        XCTAssertEqual(block.lines.count, 3)
        XCTAssertTrue(block.isCollapsed)
        XCTAssertEqual(block.startLineNumber, 1)
        XCTAssertEqual(block.endLineNumber, 3)
    }
    
    /// 测试差异项目组织功能
    func testOrganizeDiffItems() {
        let diffLines = [
            DiffLine(content: "added line", type: .added, oldLineNumber: nil, newLineNumber: 1),
            DiffLine(content: "unchanged 1", type: .unchanged, oldLineNumber: 1, newLineNumber: 2),
            DiffLine(content: "unchanged 2", type: .unchanged, oldLineNumber: 2, newLineNumber: 3),
            DiffLine(content: "unchanged 3", type: .unchanged, oldLineNumber: 3, newLineNumber: 4),
            DiffLine(content: "unchanged 4", type: .unchanged, oldLineNumber: 4, newLineNumber: 5),
            DiffLine(content: "removed line", type: .removed, oldLineNumber: 5, newLineNumber: nil)
        ]
        
        let items = DiffAlgorithm.organizeDiffItems(from: diffLines, minUnchangedLines: 3)
        
        XCTAssertEqual(items.count, 3) // added line + collapsible block + removed line
        
        // 检查第一个项目是添加的行
        if case .line(let line) = items[0] {
            XCTAssertEqual(line.type, .added)
        } else {
            XCTFail("第一个项目应该是添加的行")
        }
        
        // 检查第二个项目是折叠块
        if case .collapsibleBlock(let block) = items[1] {
            XCTAssertEqual(block.lines.count, 4)
            XCTAssertTrue(block.isCollapsed)
        } else {
            XCTFail("第二个项目应该是折叠块")
        }
        
        // 检查第三个项目是删除的行
        if case .line(let line) = items[2] {
            XCTAssertEqual(line.type, .removed)
        } else {
            XCTFail("第三个项目应该是删除的行")
        }
    }
    
    /// 测试不满足最小行数的情况
    func testOrganizeDiffItemsWithInsufficientLines() {
        let diffLines = [
            DiffLine(content: "unchanged 1", type: .unchanged, oldLineNumber: 1, newLineNumber: 1),
            DiffLine(content: "unchanged 2", type: .unchanged, oldLineNumber: 2, newLineNumber: 2),
            DiffLine(content: "added line", type: .added, oldLineNumber: nil, newLineNumber: 3)
        ]
        
        let items = DiffAlgorithm.organizeDiffItems(from: diffLines, minUnchangedLines: 3)
        
        XCTAssertEqual(items.count, 3) // 所有行都应该是普通行，因为未变动行数不够
        
        for item in items {
            if case .line(_) = item {
                // 正确
            } else {
                XCTFail("所有项目都应该是普通行")
            }
        }
    }
    
    /// 测试空差异行数组
    func testOrganizeDiffItemsWithEmptyArray() {
        let diffLines: [DiffLine] = []
        let items = DiffAlgorithm.organizeDiffItems(from: diffLines, minUnchangedLines: 3)
        
        XCTAssertTrue(items.isEmpty)
    }
    
    /// 测试只有变动行的情况
    func testOrganizeDiffItemsWithOnlyChangedLines() {
        let diffLines = [
            DiffLine(content: "added line 1", type: .added, oldLineNumber: nil, newLineNumber: 1),
            DiffLine(content: "removed line 1", type: .removed, oldLineNumber: 1, newLineNumber: nil),
            DiffLine(content: "added line 2", type: .added, oldLineNumber: nil, newLineNumber: 2)
        ]
        
        let items = DiffAlgorithm.organizeDiffItems(from: diffLines, minUnchangedLines: 3)
        
        XCTAssertEqual(items.count, 3)
        
        for item in items {
            if case .line(_) = item {
                // 正确
            } else {
                XCTFail("所有项目都应该是普通行")
            }
        }
    }
}