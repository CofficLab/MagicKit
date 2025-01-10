import SwiftUI

/// Image 的扩展，提供常用的系统图标
public extension Image {
    // MARK: - 文档相关
    
    /// 复制图标 (doc.on.doc)
    ///
    /// 用于表示复制操作或文档复制功能
    /// ```swift
    /// Button(action: copyDocument) {
    ///     Image.doc
    /// }
    /// ```
    static var doc: Image {
        Image(systemName: .iconDoc)
    }
    
    /// 文档图标 (doc)
    ///
    /// 用于表示单个文档或文件
    /// ```swift
    /// Label("新建文档", systemImage: .iconDocument)
    /// ```
    static var document: Image {
        Image(systemName: .iconDocument)
    }
    
    /// 文件夹图标 (folder)
    ///
    /// 用于表示文件夹或目录
    /// ```swift
    /// NavigationLink(destination: FolderView()) {
    ///     Label("文件夹", image: .folder)
    /// }
    /// ```
    static var folder: Image {
        Image(systemName: .iconFolder)
    }

    /// 文件夹填充图标 (folder.fill)
    static var folderFill: Image {
        Image(systemName: .iconFolderFill)
    }

    /// iCloud 文件夹图标 (folder.badge.questionmark)
    static var iCloudFolder: Image {
        Image(systemName: .iconICloudFolder)
    }

    /// 文本文档图标 (doc.text)
    static var textDocument: Image {
        Image(systemName: .iconTextDocument)
    }

    /// PDF文档图标 (doc.text.fill)
    static var pdfDocument: Image {
        Image(systemName: .iconPDFDocument)
    }

    /// 图片文档图标 (photo)
    static var imageDocument: Image {
        Image(systemName: .iconImageDocument)
    }

    /// 视频文档图标 (video)
    static var videoDocument: Image {
        Image(systemName: .iconVideoDocument)
    }

    /// 音频文档图标 (music.note)
    static var audioDocument: Image {
        Image(systemName: .iconAudioDocument)
    }

    /// 压缩文档图标 (doc.zipper)
    static var zipDocument: Image {
        Image(systemName: .iconZipDocument)
    }

    // MARK: - 操作相关

    /// 清除图标 (trash)
    static var trash: Image {
        Image(systemName: .iconTrash)
    }

    /// 清除填充图标 (trash.fill)
    static var trashFill: Image {
        Image(systemName: .iconTrashFill)
    }

    /// 勾选图标 (checkmark.circle.fill)
    static var checkmark: Image {
        Image(systemName: .iconCheckmark)
    }

    /// 错误图标 (exclamationmark.circle.fill)
    static var error: Image {
        Image(systemName: .iconError)
    }

    /// 警告图标 (exclamationmark.triangle.fill)
    static var warning: Image {
        Image(systemName: .iconWarning)
    }

    /// 信息图标 (info.circle)
    static var info: Image {
        Image(systemName: .iconInfo)
    }

    /// 关闭图标 (xmark.circle.fill)
    static var close: Image {
        Image(systemName: .iconClose)
    }

    /// 添加图标 (plus.circle)
    static var add: Image {
        Image(systemName: .iconAdd)
    }

    /// 减少图标 (minus.circle)
    static var minus: Image {
        Image(systemName: .iconMinus)
    }

    /// 搜索图标 (magnifyingglass)
    static var search: Image {
        Image(systemName: .iconSearch)
    }

    /// 刷新图标 (arrow.clockwise)
    static var refresh: Image {
        Image(systemName: .iconRefresh)
    }

    /// 设置图标 (gearshape)
    static var settings: Image {
        Image(systemName: .iconSettings)
    }

    /// 设置填充图标 (gearshape.fill)
    static var settingsFill: Image {
        Image(systemName: .iconSettingsFill)
    }

    /// 编辑图标 (pencil)
    static var edit: Image {
        Image(systemName: .iconEdit)
    }

    /// 编辑圆形图标 (pencil.circle)
    static var editCircle: Image {
        Image(systemName: .iconEditCircle)
    }

    /// 编辑填充图标 (pencil.circle.fill)
    static var editCircleFill: Image {
        Image(systemName: .iconEditCircleFill)
    }

    /// 分享图标 (square.and.arrow.up)
    static var share: Image {
        Image(systemName: .iconShare)
    }

    /// 链接图标 (link)
    static var link: Image {
        Image(systemName: .iconLink)
    }

    /// 复制图标 (doc.on.doc)
    static var copy: Image {
        Image(systemName: .iconCopy)
    }

    /// 剪切图标 (scissors)
    static var cut: Image {
        Image(systemName: .iconCut)
    }

    /// 粘贴图标 (doc.on.clipboard)
    static var paste: Image {
        Image(systemName: .iconPaste)
    }

    // MARK: - 媒体控制

    /// 播放图标 (play.circle)
    static var play: Image {
        Image(systemName: .iconPlay)
    }

    /// 播放填充图标 (play.fill)
    static var playFill: Image {
        Image(systemName: .iconPlayFill)
    }

    /// 暂停图标 (pause.circle)
    static var pause: Image {
        Image(systemName: .iconPause)
    }

    /// 暂停填充图标 (pause.fill)
    static var pauseFill: Image {
        Image(systemName: .iconPauseFill)
    }

    /// 停止图标 (stop.circle)
    static var stop: Image {
        Image(systemName: .iconStop)
    }

    /// 快进图标 (forward)
    static var forward: Image {
        Image(systemName: .iconForward)
    }

    /// 快退图标 (backward)
    static var backward: Image {
        Image(systemName: .iconBackward)
    }

    /// 快进填充图标 (forward.end.fill)
    static var forwardEndFill: Image {
        Image(systemName: .iconForwardEndFill)
    }

    /// 快退填充图标 (backward.end.fill)
    static var backwardEndFill: Image {
        Image(systemName: .iconBackwardEndFill)
    }

    /// 快进10秒图标 (goforward.10)
    static var goforward10: Image {
        Image(systemName: .iconGoforward10)
    }

    /// 快退10秒图标 (gobackward.10)
    static var gobackward10: Image {
        Image(systemName: .iconGobackward10)
    }

    /// 音量图标 (speaker.wave.2)
    static var volume: Image {
        Image(systemName: .iconVolume)
    }

    /// 静音图标 (speaker.slash)
    static var mute: Image {
        Image(systemName: .iconMute)
    }

    /// 音量调节图标 (slider.horizontal.3)
    static var volumeSlider: Image {
        Image(systemName: .iconVolumeSlider)
    }

    /// 全屏图标 (arrow.up.left.and.arrow.down.right)
    static var fullscreen: Image {
        Image(systemName: .iconFullscreen)
    }

    /// 退出全屏图标 (arrow.down.right.and.arrow.up.left)
    static var exitFullscreen: Image {
        Image(systemName: .iconExitFullscreen)
    }

    // MARK: - 播放列表

    /// 列表图标 (list.bullet)
    static var list: Image {
        Image(systemName: .iconList)
    }

    /// 列表填充图标 (list.bullet.circle.fill)
    static var listCircleFill: Image {
        Image(systemName: .iconListCircleFill)
    }

    /// 列表圆形图标 (list.bullet.circle)
    static var listCircle: Image {
        Image(systemName: .iconListCircle)
    }

    /// 网格图标 (square.grid.2x2)
    static var grid: Image {
        Image(systemName: .iconGrid)
    }

    /// 网格填充图标 (square.grid.2x2.fill)
    static var gridFill: Image {
        Image(systemName: .iconGridFill)
    }

    /// 排序图标 (arrow.up.arrow.down)
    static var sort: Image {
        Image(systemName: .iconSort)
    }

    /// 筛选图标 (line.3.horizontal.decrease.circle)
    static var filter: Image {
        Image(systemName: .iconFilter)
    }

    // MARK: - 用户和订阅

    /// 用户图标 (person.circle)
    static var user: Image {
        Image(systemName: .iconUser)
    }

    /// 用户填充图标 (person.circle.fill)
    static var userFill: Image {
        Image(systemName: .iconUserFill)
    }

    /// 用户组图标 (person.2.circle)
    static var personGroup: Image {
        Image(systemName: .iconPersonGroup)
    }

    /// 用户组填充图标 (person.2.circle.fill)
    static var personGroupFill: Image {
        Image(systemName: .iconPersonGroupFill)
    }

    /// 添加用户图标 (person.badge.plus)
    static var addUser: Image {
        Image(systemName: .iconAddUser)
    }

    /// 删除用户图标 (person.badge.minus)
    static var removeUser: Image {
        Image(systemName: .iconRemoveUser)
    }

    // MARK: - 音乐和媒体

    /// 音符图标 (music.note)
    static var musicNote: Image {
        Image(systemName: .iconMusicNote)
    }

    /// 音符列表图标 (music.note.list)
    static var musicNoteList: Image {
        Image(systemName: .iconMusicNoteList)
    }

    /// 随机播放图标 (shuffle)
    static var shuffle: Image {
        Image(systemName: .iconShuffle)
    }

    /// 单曲循环图标 (repeat.1)
    static var repeat1: Image {
        Image(systemName: .iconRepeat1)
    }

    /// 列表循环图标 (repeat)
    static var repeatAll: Image {
        Image(systemName: .iconRepeatAll)
    }

    /// 艺术家图标 (music.mic)
    static var artist: Image {
        Image(systemName: .iconArtist)
    }

    /// 专辑图标 (square.stack)
    static var album: Image {
        Image(systemName: .iconAlbum)
    }

    /// 歌词图标 (text.quote)
    static var lyrics: Image {
        Image(systemName: .iconLyrics)
    }

    /// 均衡器图标 (waveform.path.ecg)
    static var equalizer: Image {
        Image(systemName: .iconEqualizer)
    }

    // MARK: - 终端和日志

    /// 终端图标 (terminal)
    static var terminal: Image {
        Image(systemName: .iconTerminal)
    }

    /// 终端填充图标 (terminal.fill)
    static var terminalFill: Image {
        Image(systemName: .iconTerminalFill)
    }

    /// 终端图标 (apple.terminal)
    static var appleTerminal: Image {
        Image(systemName: .iconAppleTerminal)
    }

    /// 控制台图标 (keyboard)
    static var console: Image {
        Image(systemName: .iconConsole)
    }

    /// 日志图标 (text.alignleft)
    static var log: Image {
        Image(systemName: .iconLog)
    }

    /// 调试图标 (ladybug)
    static var debug: Image {
        Image(systemName: .iconDebug)
    }

    // MARK: - 下载和云存储

    /// iCloud下载图标 (arrow.down.circle.dotted)
    static var iCloudDownload: Image {
        Image(systemName: .iconICloudDownload)
    }

    /// 下载图标 (arrow.down.circle)
    static var download: Image {
        Image(systemName: .iconDownload)
    }

    /// 上传图标 (arrow.up.circle)
    static var upload: Image {
        Image(systemName: .iconUpload)
    }

    /// 云存储图标 (cloud)
    static var cloud: Image {
        Image(systemName: .iconCloud)
    }

    /// 云存储填充图标 (cloud.fill)
    static var cloudFill: Image {
        Image(systemName: .iconCloudFill)
    }

    /// 云下载图标 (cloud.download)
    static var cloudDownload: Image {
        Image(systemName: .iconCloudDownload)
    }

    /// 云上传图标 (cloud.upload)
    static var cloudUpload: Image {
        Image(systemName: .iconCloudUpload)
    }

    // MARK: - 系统状态

    /// 占位图标 (placeholder)
    static var placeholder: Image {
        Image(systemName: .iconPlaceholder)
    }

    /// 电池图标 (battery.100)
    static var battery: Image {
        Image(systemName: .iconBattery)
    }

    /// WiFi图标 (wifi)
    static var wifi: Image {
        Image(systemName: .iconWiFi)
    }

    /// 蓝牙图标 (bluetooth)
    static var bluetooth: Image {
        Image(systemName: .iconBluetooth)
    }

    /// 飞行模式图标 (airplane)
    static var airplane: Image {
        Image(systemName: .iconAirplane)
    }

    /// 定位图标 (location)
    static var location: Image {
        Image(systemName: .iconLocation)
    }

    /// 定位填充图标 (location.fill)
    static var locationFill: Image {
        Image(systemName: .iconLocationFill)
    }

    /// 时钟图标 (clock)
    static var clock: Image {
        Image(systemName: .iconClock)
    }

    /// 时钟填充图标 (clock.fill)
    static var clockFill: Image {
        Image(systemName: .iconClockFill)
    }

    /// 日历图标 (calendar)
    static var calendar: Image {
        Image(systemName: .iconCalendar)
    }

    /// 日历填充图标 (calendar.fill)
    static var calendarFill: Image {
        Image(systemName: .iconCalendarFill)
    }

    // MARK: - 通知和消息

    /// 通知图标 (bell)
    static var notification: Image {
        Image(systemName: .iconNotification)
    }

    /// 通知填充图标 (bell.fill)
    static var notificationFill: Image {
        Image(systemName: .iconNotificationFill)
    }

    /// 消息图标 (message)
    static var message: Image {
        Image(systemName: .iconMessage)
    }

    /// 消息填充图标 (message.fill)
    static var messageFill: Image {
        Image(systemName: .iconMessageFill)
    }

    /// 邮件图标 (envelope)
    static var mail: Image {
        Image(systemName: .iconMail)
    }

    /// 邮件填充图标 (envelope.fill)
    static var mailFill: Image {
        Image(systemName: .iconMailFill)
    }

    // MARK: - 社交和分享

    /// 喜欢图标 (heart)
    static var heart: Image {
        Image(systemName: .iconHeart)
    }

    /// 喜欢填充图标 (heart.fill)
    static var heartFill: Image {
        Image(systemName: .iconHeartFill)
    }

    /// 星标图标 (star)
    static var star: Image {
        Image(systemName: .iconStar)
    }

    /// 星标填充图标 (star.fill)
    static var starFill: Image {
        Image(systemName: .iconStarFill)
    }

    /// 评论图标 (bubble.right)
    static var comment: Image {
        Image(systemName: .iconComment)
    }

    /// 评论填充图标 (bubble.right.fill)
    static var commentFill: Image {
        Image(systemName: .iconCommentFill)
    }

    /// 分享图标 (square.and.arrow.up)
    static var shareAlt: Image {
        Image(systemName: .iconShareAlt)
    }

    /// 链接图标 (link.circle)
    static var linkCircle: Image {
        Image(systemName: .iconLinkCircle)
    }
}

#if DEBUG
import SwiftUI

/// 系统图标演示视图
struct SystemIconsDemoView: View {
    var body: some View {
        TabView {
            // 文档图标演示
            MagicThemePreview {
                VStack(spacing: 20) {
                    // 文档相关图标
                    VStack(alignment: .leading, spacing: 12) {
                        Text("文档相关")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        VStack(spacing: 8) {
                            MagicKeyValue(key: "文档", value: "doc") {
                                Image.document
                            }
                            MagicKeyValue(key: "文件夹", value: "folder") {
                                Image.folder
                            }
                            MagicKeyValue(key: "文本文档", value: "doc.text") {
                                Image.textDocument
                            }
                            MagicKeyValue(key: "PDF文档", value: "doc.text.fill") {
                                Image.pdfDocument
                            }
                            MagicKeyValue(key: "图片文档", value: "photo") {
                                Image.imageDocument
                            }
                            MagicKeyValue(key: "音频文档", value: "music.note") {
                                Image.audioDocument
                            }
                        }
                        .padding()
                        .background(.background.secondary)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding()
            }
            .tabItem {
                Image(systemName: "1.circle.fill")
                Text("文档")
            }
            
            // 操作图标演示
            MagicThemePreview {
                VStack(spacing: 20) {
                    // 基础操作图标
                    VStack(alignment: .leading, spacing: 12) {
                        Text("基础操作")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        VStack(spacing: 8) {
                            MagicKeyValue(key: "添加", value: "plus.circle") {
                                Image.add
                            }
                            MagicKeyValue(key: "删除", value: "trash") {
                                Image.trash
                            }
                            MagicKeyValue(key: "编辑", value: "pencil") {
                                Image.edit
                            }
                            MagicKeyValue(key: "搜索", value: "magnifyingglass") {
                                Image.search
                            }
                            MagicKeyValue(key: "刷新", value: "arrow.clockwise") {
                                Image.refresh
                            }
                        }
                        .padding()
                        .background(.background.secondary)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    
                    // 媒体控制图标
                    VStack(alignment: .leading, spacing: 12) {
                        Text("媒体控制")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        VStack(spacing: 8) {
                            MagicKeyValue(key: "播放", value: "play.circle") {
                                Image.play
                            }
                            MagicKeyValue(key: "暂停", value: "pause.circle") {
                                Image.pause
                            }
                            MagicKeyValue(key: "停止", value: "stop.circle") {
                                Image.stop
                            }
                            MagicKeyValue(key: "音量", value: "speaker.wave.2") {
                                Image.volume
                            }
                            MagicKeyValue(key: "静音", value: "speaker.slash") {
                                Image.mute
                            }
                        }
                        .padding()
                        .background(.background.secondary)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding()
            }
            .tabItem {
                Image(systemName: "2.circle.fill")
                Text("操作")
            }
            
            // 状态图标演示
            MagicThemePreview {
                VStack(spacing: 20) {
                    // 状态图标
                    VStack(alignment: .leading, spacing: 12) {
                        Text("状态指示")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        VStack(spacing: 8) {
                            MagicKeyValue(key: "成功", value: "checkmark.circle.fill") {
                                Image.checkmark
                            }
                            MagicKeyValue(key: "错误", value: "exclamationmark.circle.fill") {
                                Image.error
                            }
                            MagicKeyValue(key: "警告", value: "exclamationmark.triangle.fill") {
                                Image.warning
                            }
                            MagicKeyValue(key: "信息", value: "info.circle") {
                                Image.info
                            }
                        }
                        .padding()
                        .background(.background.secondary)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding()
            }
            .tabItem {
                Image(systemName: "3.circle.fill")
                Text("状态")
            }
        }
    }
}

#Preview("系统图标演示") {
    NavigationStack {
        SystemIconsDemoView()
    }
}
#endif
