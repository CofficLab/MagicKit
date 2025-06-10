import Foundation

/// 差异计算算法
struct DiffAlgorithm {
    
    /// 计算两个字符串数组的差异
    static func computeDiff(oldLines: [String], newLines: [String]) -> [DiffLine] {
        var result: [DiffLine] = []
        var oldIndex = 0
        var newIndex = 0
        
        // 处理两个数组都为空的情况
        if oldLines.isEmpty && newLines.isEmpty {
            return result
        }
        
        while oldIndex < oldLines.count || newIndex < newLines.count {
            if oldIndex >= oldLines.count {
                // 只剩新行，全部标记为添加
                result.append(DiffLine(
                    content: newLines[newIndex],
                    type: .added,
                    oldLineNumber: nil,
                    newLineNumber: newIndex + 1
                ))
                newIndex += 1
            } else if newIndex >= newLines.count {
                // 只剩旧行，全部标记为删除
                result.append(DiffLine(
                    content: oldLines[oldIndex],
                    type: .removed,
                    oldLineNumber: oldIndex + 1,
                    newLineNumber: nil
                ))
                oldIndex += 1
            } else {
                let oldLine = oldLines[oldIndex]
                let newLine = newLines[newIndex]
                
                if oldLine == newLine {
                    // 行相同，标记为未改变
                    result.append(DiffLine(
                        content: oldLine,
                        type: .unchanged,
                        oldLineNumber: oldIndex + 1,
                        newLineNumber: newIndex + 1
                    ))
                    oldIndex += 1
                    newIndex += 1
                } else {
                    // 行不同，检查是否是修改还是添加/删除
                    let similarity = calculateSimilarity(oldLine, newLine)
                    
                    if similarity > 0.5 {
                        // 相似度高，标记为修改
                        result.append(DiffLine(
                            content: oldLine,
                            type: .removed,
                            oldLineNumber: oldIndex + 1,
                            newLineNumber: nil
                        ))
                        result.append(DiffLine(
                            content: newLine,
                            type: .added,
                            oldLineNumber: nil,
                            newLineNumber: newIndex + 1
                        ))
                        oldIndex += 1
                        newIndex += 1
                    } else {
                        // 相似度低，寻找最佳匹配
                        // 添加边界检查，避免数组越界导致的 Range 错误
                        let remainingOldLines = oldIndex < oldLines.count ? Array(oldLines[oldIndex...]) : []
                        if let matchIndex = findBestMatch(newLine, in: remainingOldLines, startIndex: oldIndex) {
                            // 在旧行中找到匹配，中间的行标记为删除
                            while oldIndex < matchIndex {
                                result.append(DiffLine(
                                    content: oldLines[oldIndex],
                                    type: .removed,
                                    oldLineNumber: oldIndex + 1,
                                    newLineNumber: nil
                                ))
                                oldIndex += 1
                            }
                            // 匹配的行标记为未改变
                            result.append(DiffLine(
                                content: newLine,
                                type: .unchanged,
                                oldLineNumber: oldIndex + 1,
                                newLineNumber: newIndex + 1
                            ))
                            oldIndex += 1
                            newIndex += 1
                        } else {
                            // 没找到匹配，标记为添加
                            result.append(DiffLine(
                                content: newLine,
                                type: .added,
                                oldLineNumber: nil,
                                newLineNumber: newIndex + 1
                            ))
                            newIndex += 1
                        }
                    }
                }
            }
        }
        
        return result
    }
    
    /// 将差异行组织成可折叠的项目
    /// - Parameters:
    ///   - diffLines: 原始差异行数组
    ///   - minUnchangedLines: 最小未变动行数才会折叠，默认为3行
    /// - Returns: 包含折叠块的差异项目数组
    static func organizeDiffItems(from diffLines: [DiffLine], minUnchangedLines: Int = 3) -> [DiffItem] {
        var result: [DiffItem] = []
        var currentUnchangedLines: [DiffLine] = []
        
        for line in diffLines {
            if line.type == .unchanged {
                currentUnchangedLines.append(line)
            } else {
                // 遇到变动行，处理之前累积的未变动行
                if !currentUnchangedLines.isEmpty {
                    if currentUnchangedLines.count >= minUnchangedLines {
                        // 创建折叠块
                        let startLine = currentUnchangedLines.first?.oldLineNumber ?? 1
                        let endLine = currentUnchangedLines.last?.oldLineNumber ?? 1
                        let block = CollapsibleBlock(
                            lines: currentUnchangedLines,
                            isCollapsed: true,
                            startLineNumber: startLine,
                            endLineNumber: endLine
                        )
                        result.append(.collapsibleBlock(block))
                    } else {
                        // 行数不够，直接添加为普通行
                        for unchangedLine in currentUnchangedLines {
                            result.append(.line(unchangedLine))
                        }
                    }
                    currentUnchangedLines.removeAll()
                }
                
                // 添加当前变动行
                result.append(.line(line))
            }
        }
        
        // 处理最后剩余的未变动行
        if !currentUnchangedLines.isEmpty {
            if currentUnchangedLines.count >= minUnchangedLines {
                let startLine = currentUnchangedLines.first?.oldLineNumber ?? 1
                let endLine = currentUnchangedLines.last?.oldLineNumber ?? 1
                let block = CollapsibleBlock(
                    lines: currentUnchangedLines,
                    isCollapsed: true,
                    startLineNumber: startLine,
                    endLineNumber: endLine
                )
                result.append(.collapsibleBlock(block))
            } else {
                for unchangedLine in currentUnchangedLines {
                    result.append(.line(unchangedLine))
                }
            }
        }
        
        return result
    }
    
    /// 计算两个字符串的相似度
    private static func calculateSimilarity(_ str1: String, _ str2: String) -> Double {
        let longer = str1.count > str2.count ? str1 : str2
        let shorter = str1.count > str2.count ? str2 : str1
        
        if longer.isEmpty {
            return 1.0
        }
        
        let editDistance = levenshteinDistance(str1, str2)
        return (Double(longer.count) - Double(editDistance)) / Double(longer.count)
    }
    
    /// 计算编辑距离
    private static func levenshteinDistance(_ str1: String, _ str2: String) -> Int {
        let arr1 = Array(str1)
        let arr2 = Array(str2)
        let m = arr1.count
        let n = arr2.count
        
        var dp = Array(repeating: Array(repeating: 0, count: n + 1), count: m + 1)
        
        for i in 0...m {
            dp[i][0] = i
        }
        
        for j in 0...n {
            dp[0][j] = j
        }
        
        // 添加边界检查，避免空字符串导致的范围错误
        if m > 0 && n > 0 {
            for i in 1...m {
                for j in 1...n {
                    if arr1[i-1] == arr2[j-1] {
                        dp[i][j] = dp[i-1][j-1]
                    } else {
                        dp[i][j] = min(dp[i-1][j], dp[i][j-1], dp[i-1][j-1]) + 1
                    }
                }
            }
        }
        
        return dp[m][n]
    }
    
    /// 在数组中寻找最佳匹配
    private static func findBestMatch(_ target: String, in array: [String], startIndex: Int) -> Int? {
        for (index, line) in array.enumerated() {
            if line == target {
                return startIndex + index
            }
        }
        return nil
    }
}