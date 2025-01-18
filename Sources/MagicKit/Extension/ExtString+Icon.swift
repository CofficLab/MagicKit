import Foundation
import SwiftUI

public extension String {
    // MARK: - 文档相关
    /// 复制图标名称 (doc.on.doc)
    static let iconDoc = "doc.on.doc"
    
    /// 文档图标名称 (doc)
    static let iconDocument = "doc"
    
    /// 文件夹图标名称 (folder)
    static let iconFolder = "folder"
    
    /// 文件夹填充图标名称 (folder.fill)
    static let iconFolderFill = "folder.fill"
    
    /// iCloud 文件夹图标名称 (folder.badge.questionmark)
    static let iconICloudFolder = "folder.badge.questionmark"
    
    /// 在Finder中显示图标名称 (arrow.forward.circle)
    static let iconShowInFinder = "arrow.forward.circle"
    
    /// 在Finder中显示填充图标名称 (arrow.forward.circle.fill)
    static let iconShowInFinderFill = "arrow.forward.circle.fill"
    
    /// 文本文档图标名称 (doc.text)
    static let iconTextDocument = "doc.text"
    
    /// PDF文档图标名称 (doc.text.fill)
    static let iconPDFDocument = "doc.text.fill"
    
    /// 图片文档图标名称 (photo)
    static let iconImageDocument = "photo"
    
    /// 视频文档图标名称 (video)
    static let iconVideoDocument = "video"
    
    /// 音频文档图标名称 (music.note)
    static let iconAudioDocument = "music.note"
    
    /// 压缩文档图标名称 (doc.zipper)
    static let iconZipDocument = "doc.zipper"
    
    /// 只读模式图标名称 (lock)
    static let iconReadOnly = "lock"
    
    /// 只读模式填充图标名称 (lock.fill)
    static let iconReadOnlyFill = "lock.fill"
    
    /// 文档填充内容图标 (text.badge.plus)
    static let iconDocumentFill = "text.badge.plus"
    
    /// 文档填充内容填充样式图标 (doc.text.fill)
    static let iconDocumentFillAlt = "doc.text.fill"
    
    // MARK: - 操作相关
    /// 清除图标名称 (trash)
    static let iconTrash = "trash"
    
    /// 重置图标名称 (arrow.counterclockwise)
    static let iconReset = "arrow.counterclockwise"
    
    /// 清除填充图标名称 (trash.fill)
    static let iconTrashFill = "trash.fill"
    
    /// 勾选图标名称 (checkmark.circle.fill)
    static let iconCheckmark = "checkmark.circle.fill"
    
    /// 错误图标名称 (exclamationmark.circle.fill)
    static let iconError = "exclamationmark.circle.fill"
    
    /// 警告图标名称 (exclamationmark.triangle.fill)
    static let iconWarning = "exclamationmark.triangle.fill"
    
    /// 信息图标名称 (info.circle)
    static let iconInfo = "info.circle"
    
    /// 关闭图标名称 (xmark.circle.fill)
    static let iconClose = "xmark.circle.fill"
    
    /// 添加图标名称 (plus.circle)
    static let iconAdd = "plus.circle"
    
    /// 减少图标名称 (minus.circle)
    static let iconMinus = "minus.circle"
    
    /// 搜索图标名称 (magnifyingglass)
    static let iconSearch = "magnifyingglass"
    
    /// 刷新图标名称 (arrow.clockwise)
    static let iconRefresh = "arrow.clockwise"
    
    /// 设置图标名称 (gearshape)
    static let iconSettings = "gearshape"
    
    /// 设置填充图标名称 (gearshape.fill)
    static let iconSettingsFill = "gearshape.fill"
    
    /// 编辑图标名称 (pencil)
    static let iconEdit = "pencil"
    
    /// 编辑圆形图标名称 (pencil.circle)
    static let iconEditCircle = "pencil.circle"
    
    /// 编辑填充图标名称 (pencil.circle.fill)
    static let iconEditCircleFill = "pencil.circle.fill"
    
    /// 分享图标名称 (square.and.arrow.up)
    static let iconShare = "square.and.arrow.up"
    
    /// 链接图标名称 (link)
    static let iconLink = "link"
    
    /// 复制图标名称 (doc.on.doc)
    static let iconCopy = "doc.on.doc"
    
    /// 剪切图标名称 (scissors)
    static let iconCut = "scissors"
    
    /// 粘贴图标名称 (doc.on.clipboard)
    static let iconPaste = "doc.on.clipboard"
    
    // MARK: - 媒体控制
    /// 播放图标名称 (play.circle)
    static let iconPlay = "play.circle"
    
    /// 播放填充图标名称 (play.fill)
    static let iconPlayFill = "play.fill"
    
    /// 暂停图标名称 (pause.circle)
    static let iconPause = "pause.circle"
    
    /// 暂停填充图标名称 (pause.fill)
    static let iconPauseFill = "pause.fill"
    
    /// 停止图标名称 (stop.circle)
    static let iconStop = "stop.circle"
    
    /// 快进图标名称 (forward)
    static let iconForward = "forward"
    
    /// 快退图标名称 (backward)
    static let iconBackward = "backward"
    
    /// 快进填充图标名称 (forward.end.fill)
    static let iconForwardEndFill = "forward.end.fill"
    
    /// 快退填充图标名称 (backward.end.fill)
    static let iconBackwardEndFill = "backward.end.fill"
    
    /// 快进10秒图标名称 (goforward.10)
    static let iconGoforward10 = "goforward.10"
    
    /// 快退10秒图标名称 (gobackward.10)
    static let iconGobackward10 = "gobackward.10"
    
    /// 音量图标名称 (speaker.wave.2)
    static let iconVolume = "speaker.wave.2"
    
    /// 静音图标名称 (speaker.slash)
    static let iconMute = "speaker.slash"
    
    /// 音量调节图标名称 (slider.horizontal.3)
    static let iconVolumeSlider = "slider.horizontal.3"
    
    /// 全屏图标名称 (arrow.up.left.and.arrow.down.right)
    static let iconFullscreen = "arrow.up.left.and.arrow.down.right"
    
    /// 退出全屏图标名称 (arrow.down.right.and.arrow.up.left)
    static let iconExitFullscreen = "arrow.down.right.and.arrow.up.left"
    
    // MARK: - 播放列表
    /// 列表图标名称 (list.bullet)
    static let iconList = "list.bullet"
    
    /// 列表填充图标名称 (list.bullet.circle.fill)
    static let iconListCircleFill = "list.bullet.circle.fill"
    
    /// 列表圆形图标名称 (list.bullet.circle)
    static let iconListCircle = "list.bullet.circle"
    
    /// 网格图标名称 (square.grid.2x2)
    static let iconGrid = "square.grid.2x2"
    
    /// 网格填充图标名称 (square.grid.2x2.fill)
    static let iconGridFill = "square.grid.2x2.fill"
    
    /// 排序图标名称 (arrow.up.arrow.down)
    static let iconSort = "arrow.up.arrow.down"
    
    /// 筛选图标名称 (line.3.horizontal.decrease.circle)
    static let iconFilter = "line.3.horizontal.decrease.circle"
    
    // MARK: - 用户和订阅
    /// 用户图标名称 (person.circle)
    static let iconUser = "person.circle"
    
    /// 用户填充图标名称 (person.circle.fill)
    static let iconUserFill = "person.circle.fill"
    
    /// 用户组图标名称 (person.2.circle)
    static let iconPersonGroup = "person.2.circle"
    
    /// 用户组填充图标名称 (person.2.circle.fill)
    static let iconPersonGroupFill = "person.2.circle.fill"
    
    /// 添加用户图标名称 (person.badge.plus)
    static let iconAddUser = "person.badge.plus"
    
    /// 删除用户图标名称 (person.badge.minus)
    static let iconRemoveUser = "person.badge.minus"
    
    // MARK: - 音乐和媒体
    /// 音符图标名称 (music.note)
    static let iconMusicNote = "music.note"
    
    /// 音符列表图标名称 (music.note.list)
    static let iconMusicNoteList = "music.note.list"
    
    /// 随机播放图标名称 (shuffle)
    static let iconShuffle = "shuffle"
    
    /// 单曲循环图标名称 (repeat.1)
    static let iconRepeat1 = "repeat.1"
    
    /// 列表循环图标名称 (repeat)
    static let iconRepeatAll = "repeat"
    
    /// 艺术家图标名称 (music.mic)
    static let iconArtist = "music.mic"
    
    /// 专辑图标名称 (square.stack)
    static let iconAlbum = "square.stack"
    
    /// 歌词图标名称 (text.quote)
    static let iconLyrics = "text.quote"
    
    /// 均衡器图标名称 (waveform.path.ecg)
    static let iconEqualizer = "waveform.path.ecg"
    
    // MARK: - 终端和日志
    /// 终端图标名称 (terminal)
    static let iconTerminal = "terminal"
    
    /// 终端填充图标名称 (terminal.fill)
    static let iconTerminalFill = "terminal.fill"
    
    /// 终端图标名称 (apple.terminal)
    static let iconAppleTerminal = "apple.terminal"
    
    /// 控制台图标名称 (keyboard)
    static let iconConsole = "keyboard"
    
    /// 日志图标名称 (text.alignleft)
    static let iconLog = "text.alignleft"
    
    /// 调试图标名称 (ladybug)
    static let iconDebug = "ladybug"
    
    // MARK: - 下载和云存储
    /// iCloud下载图标名称 (arrow.down.circle.dotted)
    static let iconICloudDownload = "arrow.down.circle.dotted"
    
    /// 下载图标名称 (arrow.down.circle)
    static let iconDownload = "arrow.down.circle"
    
    /// 上传图标名称 (arrow.up.circle)
    static let iconUpload = "arrow.up.circle"
    
    /// 云存储图标名称 (cloud)
    static let iconCloud = "cloud"
    
    /// 云存储填充图标名称 (cloud.fill)
    static let iconCloudFill = "cloud.fill"
    
    /// 云下载图标名称 (cloud.download)
    static let iconCloudDownload = "cloud.download"
    
    /// 云上传图标名称 (icloud.and.arrow.up)
    static let iconCloudUpload = "icloud.and.arrow.up"
    
    // MARK: - 系统状态
    /// 占位图标名称 (placeholder)
    static let iconPlaceholder = "placeholder"
    
    /// 电池图标名称 (battery.100)
    static let iconBattery = "battery.100"
    
    /// WiFi图标名称 (wifi)
    static let iconWiFi = "wifi"
    
    /// 蓝牙图标名称 (bluetooth)
    static let iconBluetooth = "bluetooth"
    
    /// 飞行模式图标名称 (airplane)
    static let iconAirplane = "airplane"
    
    /// 定位图标名称 (location)
    static let iconLocation = "location"
    
    /// 定位填充图标名称 (location.fill)
    static let iconLocationFill = "location.fill"
    
    /// 时钟图标名称 (clock)
    static let iconClock = "clock"
    
    /// 时钟填充图标名称 (clock.fill)
    static let iconClockFill = "clock.fill"
    
    /// 日历图标名称 (calendar)
    static let iconCalendar = "calendar"
    
    /// 日历填充图标名称 (calendar.fill)
    static let iconCalendarFill = "calendar.fill"
    
    // MARK: - 通知和消息
    /// 通知图标名称 (bell)
    static let iconNotification = "bell"
    
    /// 通知填充图标名称 (bell.fill)
    static let iconNotificationFill = "bell.fill"
    
    /// 消息图标名称 (message)
    static let iconMessage = "message"
    
    /// 消息填充图标名称 (message.fill)
    static let iconMessageFill = "message.fill"
    
    /// 邮件图标名称 (envelope)
    static let iconMail = "envelope"
    
    /// 邮件填充图标名称 (envelope.fill)
    static let iconMailFill = "envelope.fill"
    
    // MARK: - 社交和分享
    /// 喜欢图标名称 (heart)
    static let iconHeart = "heart"
    
    /// 喜欢填充图标名称 (heart.fill)
    static let iconHeartFill = "heart.fill"
    
    /// 星标图标名称 (star)
    static let iconStar = "star"
    
    /// 星标填充图标名称 (star.fill)
    static let iconStarFill = "star.fill"
    
    /// 评论图标名称 (bubble.right)
    static let iconComment = "bubble.right"
    
    /// 评论填充图标名称 (bubble.right.fill)
    static let iconCommentFill = "bubble.right.fill"
    
    /// 分享图标名称 (square.and.arrow.up)
    static let iconShareAlt = "square.and.arrow.up"
    
    /// 链接图标名称 (link.circle)
    static let iconLinkCircle = "link.circle"
    
    // MARK: - 应用程序
    /// Safari浏览器图标名称 (safari)
    static let iconSafari = "safari"
    
    /// Safari浏览器填充图标名称 (safari.fill)
    static let iconSafariFill = "safari.fill"
    
    /// App Store图标名称 (app.store)
    static let iconAppStore = "app.store"
    
    /// 系统设置图标名称 (gearshape.2)
    static let iconSystemSettings = "gearshape.2"
    
    /// 系统设置填充图标名称 (gearshape.2.fill)
    static let iconSystemSettingsFill = "gearshape.2.fill"
    
    /// 访达图标名称 (macwindow)
    static let iconFinder = "macwindow"
    
    /// 访达填充图标名称 (macwindow.fill)
    static let iconFinderFill = "macwindow.fill"
    
    /// 邮件图标名称 (envelope.badge)
    static let iconMailApp = "envelope.badge"
    
    /// 邮件填充图标名称 (envelope.badge.fill)
    static let iconMailAppFill = "envelope.badge.fill"
    
    /// 信息图标名称 (message.badge)
    static let iconMessages = "message.badge"
    
    /// 信息填充图标名称 (message.badge.fill)
    static let iconMessagesFill = "message.badge.fill"
    
    /// 音乐图标名称 (music.note.house)
    static let iconMusic = "music.note.house"
    
    /// 音乐填充图标名称 (music.note.house.fill)
    static let iconMusicFill = "music.note.house.fill"
    
    /// 照片图标名称 (photo.on.rectangle)
    static let iconPhotos = "photo.on.rectangle"
    
    /// 照片填充图标名称 (photo.on.rectangle.fill)
    static let iconPhotosFill = "photo.on.rectangle.fill"
    
    /// 地图图标名称 (map)
    static let iconMaps = "map"
    
    /// 地图填充图标名称 (map.fill)
    static let iconMapsFill = "map.fill"
    
    /// 提醒事项图标名称 (list.bullet.rectangle)
    static let iconReminders = "list.bullet.rectangle"
    
    /// 提醒事项填充图标名称 (list.bullet.rectangle.fill)
    static let iconRemindersFill = "list.bullet.rectangle.fill"
    
    /// 备忘录图标名称 (note.text)
    static let iconNotes = "note.text"
    
    /// 备忘录填充图标名称 (note.text.fill)
    static let iconNotesFill = "note.text.fill"
    
    /// 日历图标名称 (calendar.badge.clock)
    static let iconCalendarApp = "calendar.badge.clock"
    
    /// 日历填充图标名称 (calendar.badge.clock.fill)
    static let iconCalendarAppFill = "calendar.badge.clock.fill"
    
    /// FaceTime图标名称 (video.badge)
    static let iconFaceTime = "video.badge"
    
    /// FaceTime填充图标名称 (video.badge.fill)
    static let iconFaceTimeFill = "video.badge.fill"
    
    /// 通讯录图标名称 (person.crop.rectangle)
    static let iconContacts = "person.crop.rectangle"
    
    /// 通讯录填充图标名称 (person.crop.rectangle.fill)
    static let iconContactsFill = "person.crop.rectangle.fill"
    
    /// 计算器图标名称 (plus.slash.minus)
    static let iconCalculator = "plus.slash.minus"
    
    /// 语音备忘录图标名称 (waveform)
    static let iconVoiceMemos = "waveform"
    
    /// 语音备忘录填充图标名称 (waveform.fill)
    static let iconVoiceMemosFill = "waveform.fill"
    
    /// 时钟应用图标名称 (clock.badge)
    static let iconClockApp = "clock.badge"
    
    /// 时钟应用填充图标名称 (clock.badge.fill)
    static let iconClockAppFill = "clock.badge.fill"
    
    /// 天气图标名称 (cloud.sun)
    static let iconWeather = "cloud.sun"
    
    /// 天气填充图标名称 (cloud.sun.fill)
    static let iconWeatherFill = "cloud.sun.fill"
    
    /// 股市图标名称 (chart.line.uptrend.xyaxis)
    static let iconStocks = "chart.line.uptrend.xyaxis"
    
    /// 股市填充图标名称 (chart.line.uptrend.xyaxis.fill)
    static let iconStocksFill = "chart.line.uptrend.xyaxis.fill"
    
    /// 家庭图标名称 (house)
    static let iconHome = "house"
    
    /// 家庭填充图标名称 (house.fill)
    static let iconHomeFill = "house.fill"
    
    /// 快捷指令图标名称 (command.square)
    static let iconShortcuts = "command.square"
    
    /// 快捷指令填充图标名称 (command.square.fill)
    static let iconShortcutsFill = "command.square.fill"
    
    /// 活动记录图标名称 (flame)
    static let iconActivity = "flame"
    
    /// 活动记录填充图标名称 (flame.fill)
    static let iconActivityFill = "flame.fill"
    
    /// 健康图标名称 (heart.text.square)
    static let iconHealth = "heart.text.square"
    
    /// 健康填充图标名称 (heart.text.square.fill)
    static let iconHealthFill = "heart.text.square.fill"
    
    /// 钱包图标名称 (wallet.pass)
    static let iconWallet = "wallet.pass"
    
    /// 钱包填充图标名称 (wallet.pass.fill)
    static let iconWalletFill = "wallet.pass.fill"
    
    /// 密码图标名称 (key)
    static let iconPasswords = "key"
    
    /// 密码填充图标名称 (key.fill)
    static let iconPasswordsFill = "key.fill"
    
    /// 终端图标名称 (terminal.fill)
    static let iconTerminalApp = "terminal.fill"
    
    /// Xcode图标名称 (hammer)
    static let iconXcode = "hammer"
    
    /// Xcode填充图标名称 (hammer.fill)
    static let iconXcodeFill = "hammer.fill"
    
    /// 预览图标名称 (doc.richtext)
    static let iconPreview = "doc.richtext"
    
    /// 预览填充图标名称 (doc.richtext.fill)
    static let iconPreviewFill = "doc.richtext.fill"
    
    /// QuickTime图标名称 (play.rectangle)
    static let iconQuickTime = "play.rectangle"
    
    /// QuickTime填充图标名称 (play.rectangle.fill)
    static let iconQuickTimeFill = "play.rectangle.fill"
    
    /// TextEdit图标名称 (doc.text.below.ecg)
    static let iconTextEdit = "doc.text.below.ecg"
    
    /// TextEdit填充图标名称 (doc.text.below.ecg.fill)
    static let iconTextEditFill = "doc.text.below.ecg.fill"
    
    // MARK: - 形状和边框
    /// 正方形图标名称 (square)
    static let iconSquare = "square"
    
    /// 虚线正方形图标名称 (square.dashed)
    static let iconSquareDashed = "square.dashed"
    
    /// 圆形叠加正方形图标名称 (square.on.circle)
    static let iconSquareOnCircle = "square.on.circle"
    
    /// 人物裁剪圆形图标名称 (person.crop.circle)
    static let iconPersonCropCircle = "person.crop.circle"
    
    /// 标尺图标名称 (ruler)
    static let iconRuler = "ruler"
    
    /// 地球图标名称 (globe)
    static let iconGlobe = "globe"

    // MARK: - 安全相关
    /// 指纹图标名称 (touchid)
    static let iconFingerprint = "touchid"
    
    /// 指纹填充图标名称 (touchid.fill)
    static let iconFingerprintFill = "touchid.fill"
    
    /// 二进制文档图标名称 (doc.text.fill.viewfinder)
    static let iconDocBinary = "doc.text.fill.viewfinder"
    
    // MARK: - 开发和调试
    /// 代码图标名称 (chevron.left.forwardslash.chevron.right)
    static let iconCode = "chevron.left.forwardslash.chevron.right"
    
    /// 更多图标名称 (ellipsis)
    static let iconMore = "ellipsis"
    
    /// 画笔图标名称 (paintbrush)
    static let iconPaintbrush = "paintbrush"
    
    /// 调色板图标名称 (paintpalette)
    static let iconPaintpalette = "paintpalette"
    
    /// 下载云图标名称 (icloud.and.arrow.down)
    static let iconICloudDownloadAlt = "icloud.and.arrow.down"
    
    /// 用户组禁用图标名称 (person.2.slash)
    static let iconPersonGroupSlash = "person.2.slash"
    
    /// 向下箭头图标名称 (chevron.down)
    static let iconChevronDown = "chevron.down"
    
    /// 音符圆形图标名称 (music.note.circle)
    static let iconMusicNoteCircle = "music.note.circle"
    
    /// 音量填充图标名称 (speaker.wave.2.fill)
    static let iconVolumeFill = "speaker.wave.2.fill"
    
    /// 勾选图标名称 (checkmark)
    static let iconCheckmarkSimple = "checkmark"
    
    /// 电影图标名称 (film)
    static let iconFilm = "film"
    
    /// 加号图标名称 (plus)
    static let iconPlus = "plus"
    
    // MARK: - 数字相关
    /// 数字1填充圆形图标名称 (1.circle.fill)
    static let iconNumberCircleFill1 = "1.circle.fill"
    
    /// 数字2填充圆形图标名称 (2.circle.fill)
    static let iconNumberCircleFill2 = "2.circle.fill"
    
    /// 数字3填充圆形图标名称 (3.circle.fill)
    static let iconNumberCircleFill3 = "3.circle.fill"
    
    // MARK: - 时间相关    
    /// 计时器图标名称 (timer)
    static let iconTimer = "timer"
    
    /// 计时器填充图标名称 (timer.fill)
    static let iconTimerFill = "timer.fill"
    
    // MARK: - 设置相关
    /// 通知设置图标名称 (bell.badge)
    static let iconNotificationSetting = "bell.badge"
    
    /// 主题设置图标名称 (paintbrush.fill)
    static let iconThemeSetting = "paintbrush.fill"
    
    /// 音量设置图标名称 (speaker.wave.3)
    static let iconVolumeSetting = "speaker.wave.3"
    
    /// 开发者设置图标名称 (hammer.circle)
    static let iconDeveloperSetting = "hammer.circle"
    
    /// 质量设置图标名称 (dial.high.fill)
    static let iconQualitySetting = "dial.high.fill"
    
    /// 状态设置图标名称 (circle.fill)
    static let iconStatusSetting = "circle.fill"
    
    /// 缓存设置图标名称 (trash.circle)
    static let iconCacheSetting = "trash.circle"
    
    /// 连接设置图标名称 (network)
    static let iconConnectionSetting = "network"
    
    /// 账户设置图标名称 (person.circle)
    static let iconAccountSetting = "person.circle"
    
    /// 版本信息图标名称 (info.circle)
    static let iconVersionInfo = "info.circle"
    
    // MARK: - 音乐仓库
    /// 音乐仓库图标名称 (music.note.house)
    static let iconMusicLibrary = "music.note.house"
    
    /// 音乐仓库填充图标名称 (music.note.house.fill)
    static let iconMusicLibraryFill = "music.note.house.fill"
    
    /// 音乐文件夹图标名称 (folder.fill.badge.plus)
    static let iconMusicFolder = "folder.fill.badge.plus"
    
    // MARK: - 音频设备
    /// 输入设备图标名称 (mic)
    static let iconAudioInput = "mic"
    
    /// 输出设备图标名称 (speaker.wave.2.circle)
    static let iconAudioOutput = "speaker.wave.2.circle"
    
    // MARK: - 云同步
    /// 云禁用图标名称 (icloud.slash)
    static let iconCloudSlash = "icloud.slash"
    
    /// 箭头循环图标名称 (arrow.clockwise)
    static let iconArrowClockwise = "arrow.clockwise"
    
    // MARK: - 设置行图标
    /// 齿轮图标名称 (gearshape)
    static let iconGear = "gearshape"
    
    /// 向上箭头圆形图标名称 (arrow.up.circle)
    static let iconArrowUpCircle = "arrow.up.circle"
        
    /// 圆点圆形图标名称 (dot.circle)
    static let iconDotCircle = "dot.circle"
    
    /// 人物圆形图标名称 (person.circle)
    static let iconPersonCircle = "person.circle"
    
    // MARK: - 性能和质量
    /// 速度计图标名称 (gauge.medium)
    static let iconSpeedometer = "gauge.medium"
    
    /// 中速速度计图标名称 (gauge.high)
    static let iconSpeedometerMedium = "gauge.high"
    
    /// 高速速度计图标名称 (gauge.badge.plus)
    static let iconSpeedometerHigh = "gauge.badge.plus"
        
    /// 图表图标名称 (chart.bar)
    static let iconChart = "chart.bar"
    
    /// AI大脑图标名称 (brain.head.profile)
    static let iconBrain = "brain.head.profile"
    
    // MARK: - 富文本编辑
    /// 表格图标名称 (tablecells)
    static let iconTable = "tablecells"
    
    /// 表格填充图标名称 (tablecells.fill)
    static let iconTableFill = "tablecells.fill"
    
    /// 表格合并图标名称 (tablecells.badge.ellipsis)
    static let iconTableMerge = "tablecells.badge.ellipsis"
    
    /// 表格分割图标名称 (tablecells.split.horizontal)
    static let iconTableSplit = "tablecells.split.horizontal"
    
    /// 加粗图标名称 (bold)
    static let iconBold = "bold"
    
    /// 斜体图标名称 (italic)
    static let iconItalic = "italic"
    
    /// 下划线图标名称 (underline)
    static let iconUnderline = "underline"
    
    /// 删除线图标名称 (strikethrough)
    static let iconStrikethrough = "strikethrough"
    
    /// 左对齐图标名称 (text.alignleft)
    static let iconAlignLeft = "text.alignleft"
    
    /// 居中对齐图标名称 (text.aligncenter)
    static let iconAlignCenter = "text.aligncenter"
    
    /// 右对齐图标名称 (text.alignright)
    static let iconAlignRight = "text.alignright"
    
    /// 两端对齐图标名称 (text.justify)
    static let iconAlignJustify = "text.justify"
    
    /// 项目符号列表图标名称 (list.bullet)
    static let iconBulletList = "list.bullet"
    
    /// 编号列表图标名称 (list.number)
    static let iconNumberList = "list.number"
    
    /// 缩进增加图标名称 (increase.indent)
    static let iconIndentIncrease = "increase.indent"
    
    /// 缩进减少图标名称 (decrease.indent)
    static let iconIndentDecrease = "decrease.indent"
    
    /// 字体图标名称 (textformat)
    static let iconFont = "textformat"
    
    /// 字体大小图标名称 (textformat.size)
    static let iconFontSize = "textformat.size"
    
    /// 字体颜色图标名称 (textformat.alt)
    static let iconFontColor = "textformat.alt"
    
    /// 背景色图标名称 (paintbrush)
    static let iconBackgroundColor = "paintbrush"
    
    /// 超链接图标名称 (link.badge.plus)
    static let iconHyperlink = "link.badge.plus"
    
    /// 图片插入图标名称 (photo.on.rectangle.angled)
    static let iconInsertImage = "photo.on.rectangle.angled"
    
    /// 清除格式图标名称 (clear)
    static let iconClearFormat = "clear"
} 

#Preview("图标演示") {
    NavigationStack {
        StringIconExtensionDemoView()
    }
}