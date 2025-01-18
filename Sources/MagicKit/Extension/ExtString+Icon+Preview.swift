import SwiftUI

/// String+Icon 扩展功能演示视图
struct StringIconExtensionDemoView: View {
    var body: some View {
        MagicThemePreview {
            VStack(spacing: 24) {
                // 文档相关
                IconSection(title: "文档相关", icons: [
                    ("文档", .iconDocument),
                    ("文件夹", .iconFolder),
                    ("文件夹填充", .iconFolderFill),
                    ("iCloud文件夹", .iconICloudFolder),
                    ("文本", .iconTextDocument),
                    ("PDF", .iconPDFDocument),
                    ("图片", .iconImageDocument),
                    ("视频", .iconVideoDocument),
                    ("音频", .iconAudioDocument),
                    ("压缩", .iconZipDocument),
                    ("只读", .iconReadOnly),
                    ("只读填充", .iconReadOnlyFill),
                    ("填充内容", .iconDocumentFill),
                    ("填充内容备选", .iconDocumentFillAlt)
                ])
                
                // 操作相关
                IconSection(title: "操作相关", icons: [
                    ("添加", .iconAdd),
                    ("减少", .iconMinus),
                    ("删除", .iconTrash),
                    ("删除填充", .iconTrashFill),
                    ("编辑", .iconEdit),
                    ("编辑圆形", .iconEditCircle),
                    ("编辑填充", .iconEditCircleFill),
                    ("分享", .iconShare),
                    ("复制", .iconCopy),
                    ("剪切", .iconCut),
                    ("粘贴", .iconPaste),
                    ("搜索", .iconSearch),
                    ("重置", .iconReset),
                    ("刷新", .iconRefresh),
                    ("设置", .iconSettings)
                ])
                
                // 媒体控制
                IconSection(title: "媒体控制", icons: [
                    ("播放", .iconPlay),
                    ("播放填充", .iconPlayFill),
                    ("暂停", .iconPause),
                    ("暂停填充", .iconPauseFill),
                    ("停止", .iconStop),
                    ("快进", .iconForward),
                    ("快退", .iconBackward),
                    ("快进填充", .iconForwardEndFill),
                    ("快退填充", .iconBackwardEndFill),
                    ("前进10秒", .iconGoforward10),
                    ("后退10秒", .iconGobackward10),
                    ("音量", .iconVolume),
                    ("静音", .iconMute),
                    ("音量调节", .iconVolumeSlider),
                    ("全屏", .iconFullscreen),
                    ("退出全屏", .iconExitFullscreen)
                ])
                
                // 播放列表
                IconSection(title: "播放列表", icons: [
                    ("列表", .iconList),
                    ("列表圆形", .iconListCircle),
                    ("列表填充", .iconListCircleFill),
                    ("网格", .iconGrid),
                    ("网格填充", .iconGridFill),
                    ("排序", .iconSort),
                    ("筛选", .iconFilter)
                ])
                
                // 音乐和媒体
                IconSection(title: "音乐和媒体", icons: [
                    ("音符", .iconMusicNote),
                    ("音符列表", .iconMusicNoteList),
                    ("随机播放", .iconShuffle),
                    ("单曲循环", .iconRepeat1),
                    ("列表循环", .iconRepeatAll),
                    ("艺术家", .iconArtist),
                    ("专辑", .iconAlbum),
                    ("歌词", .iconLyrics),
                    ("均衡器", .iconEqualizer)
                ])
                
                // 用户和订阅
                IconSection(title: "用户和订阅", icons: [
                    ("用户", .iconUser),
                    ("用户填充", .iconUserFill),
                    ("用户组", .iconPersonGroup),
                    ("用户组填充", .iconPersonGroupFill),
                    ("添加用户", .iconAddUser),
                    ("删除用户", .iconRemoveUser),
                    ("用户组禁用", .iconPersonGroupSlash)
                ])
                
                // 系统状态
                IconSection(title: "系统状态", icons: [
                    ("电池", .iconBattery),
                    ("WiFi", .iconWiFi),
                    ("蓝牙", .iconBluetooth),
                    ("飞行模式", .iconAirplane),
                    ("定位", .iconLocation),
                    ("定位填充", .iconLocationFill),
                    ("时钟", .iconClock),
                    ("时钟填充", .iconClockFill),
                    ("日历", .iconCalendar),
                    ("日历填充", .iconCalendarFill)
                ])
                
                // 通知和消息
                IconSection(title: "通知和消息", icons: [
                    ("通知", .iconNotification),
                    ("通知填充", .iconNotificationFill),
                    ("消息", .iconMessage),
                    ("消息填充", .iconMessageFill),
                    ("邮件", .iconMail),
                    ("邮件填充", .iconMailFill),
                    ("通知设置", .iconNotificationSetting)
                ])
                
                // 社交和分享
                IconSection(title: "社交和分享", icons: [
                    ("喜欢", .iconHeart),
                    ("喜欢填充", .iconHeartFill),
                    ("星标", .iconStar),
                    ("星标填充", .iconStarFill),
                    ("评论", .iconComment),
                    ("评论填充", .iconCommentFill),
                    ("分享", .iconShareAlt),
                    ("链接", .iconLinkCircle)
                ])
                
                // 应用程序
                IconSection(title: "应用程序", icons: [
                    ("Safari", .iconSafari),
                    ("Safari填充", .iconSafariFill),
                    ("App Store", .iconAppStore),
                    ("系统设置", .iconSystemSettings),
                    ("系统设置填充", .iconSystemSettingsFill),
                    ("访达", .iconFinder),
                    ("访达填充", .iconFinderFill),
                    ("邮件", .iconMailApp),
                    ("邮件填充", .iconMailAppFill),
                    ("信息", .iconMessages),
                    ("信息填充", .iconMessagesFill),
                    ("音乐", .iconMusic),
                    ("音乐填充", .iconMusicFill),
                    ("照片", .iconPhotos),
                    ("照片填充", .iconPhotosFill)
                ])
                
                // 终端和开发
                IconSection(title: "终端和开发", icons: [
                    ("终端", .iconTerminal),
                    ("终端填充", .iconTerminalFill),
                    ("Apple终端", .iconAppleTerminal),
                    ("控制台", .iconConsole),
                    ("日志", .iconLog),
                    ("调试", .iconDebug),
                    ("代码", .iconCode),
                    ("Xcode", .iconXcode),
                    ("Xcode填充", .iconXcodeFill)
                ])
                
                // 云存储和同步
                IconSection(title: "云存储和同步", icons: [
                    ("云存储", .iconCloud),
                    ("云存储填充", .iconCloudFill),
                    ("云下载", .iconCloudDownload),
                    ("云上传", .iconCloudUpload),
                    ("云禁用", .iconCloudSlash),
                    ("iCloud下载", .iconICloudDownload),
                    ("下载", .iconDownload),
                    ("上传", .iconUpload)
                ])
                
                // 设置和性能
                IconSection(title: "设置和性能", icons: [
                    ("齿轮", .iconGear),
                    ("主题", .iconThemeSetting),
                    ("音量", .iconVolumeSetting),
                    ("开发者", .iconDeveloperSetting),
                    ("质量", .iconQualitySetting),
                    ("状态", .iconStatusSetting),
                    ("缓存", .iconCacheSetting),
                    ("连接", .iconConnectionSetting),
                    ("账户", .iconAccountSetting),
                    ("版本", .iconVersionInfo),
                    ("速度计", .iconSpeedometer),
                    ("中速", .iconSpeedometerMedium),
                    ("高速", .iconSpeedometerHigh)
                ])
                
                // 音频设备
                IconSection(title: "音频设备", icons: [
                    ("输入设备", .iconAudioInput),
                    ("输出设备", .iconAudioOutput),
                    ("音量", .iconVolume),
                    ("音量填充", .iconVolumeFill),
                    ("静音", .iconMute),
                    ("音量调节", .iconVolumeSlider)
                ])
                
                // 音乐仓库
                IconSection(title: "音乐仓库", icons: [
                    ("音乐仓库", .iconMusicLibrary),
                    ("音乐仓库填充", .iconMusicLibraryFill),
                    ("音乐文件夹", .iconMusicFolder),
                    ("音符", .iconMusicNote),
                    ("音符圆形", .iconMusicNoteCircle),
                    ("音符列表", .iconMusicNoteList)
                ])
                
                // 形状和边框
                IconSection(title: "形状和边框", icons: [
                    ("正方形", .iconSquare),
                    ("虚线正方形", .iconSquareDashed),
                    ("圆形叠加正方形", .iconSquareOnCircle),
                    ("人物裁剪圆形", .iconPersonCropCircle),
                    ("标尺", .iconRuler),
                    ("地球", .iconGlobe),
                    ("圆点圆形", .iconDotCircle)
                ])
                
                // 安全相关
                IconSection(title: "安全相关", icons: [
                    ("指纹", .iconFingerprint),
                    ("指纹填充", .iconFingerprintFill),
                    ("二进制文档", .iconDocBinary),
                    ("密码", .iconPasswords),
                    ("密码填充", .iconPasswordsFill)
                ])
                
                // 时间相关
                IconSection(title: "时间相关", icons: [
                    ("时钟", .iconClock),
                    ("时钟填充", .iconClockFill),
                    ("时钟应用", .iconClockApp),
                    ("时钟应用填充", .iconClockAppFill),
                    ("计时器", .iconTimer),
                    ("计时器填充", .iconTimerFill)
                ])
                
                // 数字相关
                IconSection(title: "数字相关", icons: [
                    ("数字1填充", .iconNumberCircleFill1),
                    ("数字2填充", .iconNumberCircleFill2),
                    ("数字3填充", .iconNumberCircleFill3)
                ])
                
                // 状态和提示
                IconSection(title: "状态和提示", icons: [
                    ("勾选", .iconCheckmark),
                    ("勾选简单", .iconCheckmarkSimple),
                    ("错误", .iconError),
                    ("警告", .iconWarning),
                    ("信息", .iconInfo),
                    ("关闭", .iconClose),
                    ("更多", .iconMore),
                    ("占位", .iconPlaceholder)
                ])
                
                // 其他应用
                IconSection(title: "其他应用", icons: [
                    ("地图", .iconMaps),
                    ("地图填充", .iconMapsFill),
                    ("提醒事项", .iconReminders),
                    ("提醒事项填充", .iconRemindersFill),
                    ("备忘录", .iconNotes),
                    ("备忘录填充", .iconNotesFill),
                    ("FaceTime", .iconFaceTime),
                    ("FaceTime填充", .iconFaceTimeFill),
                    ("通讯录", .iconContacts),
                    ("通讯录填充", .iconContactsFill),
                    ("计算器", .iconCalculator),
                    ("语音备忘录", .iconVoiceMemos),
                    ("语音备忘录填充", .iconVoiceMemosFill),
                    ("天气", .iconWeather),
                    ("天气填充", .iconWeatherFill),
                    ("股市", .iconStocks),
                    ("股市填充", .iconStocksFill),
                    ("家庭", .iconHome),
                    ("家庭填充", .iconHomeFill),
                    ("快捷指令", .iconShortcuts),
                    ("快捷指令填充", .iconShortcutsFill),
                    ("活动记录", .iconActivity),
                    ("活动记录填充", .iconActivityFill),
                    ("健康", .iconHealth),
                    ("健康填充", .iconHealthFill),
                    ("钱包", .iconWallet),
                    ("钱包填充", .iconWalletFill),
                    ("预览", .iconPreview),
                    ("预览填充", .iconPreviewFill),
                    ("QuickTime", .iconQuickTime),
                    ("QuickTime填充", .iconQuickTimeFill),
                    ("TextEdit", .iconTextEdit),
                    ("TextEdit填充", .iconTextEditFill)
                ])
                
                // 富文本编辑
                IconSection(title: "富文本编辑", icons: [
                    ("表格", .iconTable),
                    ("表格填充", .iconTableFill),
                    ("表格合并", .iconTableMerge),
                    ("表格分割", .iconTableSplit),
                    ("加粗", .iconBold),
                    ("斜体", .iconItalic),
                    ("下划线", .iconUnderline),
                    ("删除线", .iconStrikethrough),
                    ("左对齐", .iconAlignLeft),
                    ("居中对齐", .iconAlignCenter),
                    ("右对齐", .iconAlignRight),
                    ("两端对齐", .iconAlignJustify),
                    ("项目符号", .iconBulletList),
                    ("编号列表", .iconNumberList),
                    ("增加缩进", .iconIndentIncrease),
                    ("减少缩进", .iconIndentDecrease),
                    ("字体", .iconFont),
                    ("字号", .iconFontSize),
                    ("字体颜色", .iconFontColor),
                    ("背景色", .iconBackgroundColor),
                    ("超链接", .iconHyperlink),
                    ("插入图片", .iconInsertImage),
                    ("清除格式", .iconClearFormat)
                ])
            }
            .padding()
        }
    }
}

/// 图标分类展示组件
struct IconSection: View {
    let title: String
    let icons: [(String, String)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)
            
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 60))
            ], spacing: 16) {
                ForEach(icons, id: \.0) { name, systemName in
                    IconDemoItem(name: name, systemName: systemName)
                }
            }
            .padding()
            .background(.background.secondary)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

/// 图标演示项
struct IconDemoItem: View {
    let name: String
    let systemName: String
    
    var body: some View {
        VStack {
            Image(systemName: systemName)
                .font(.title2)
                .frame(height: 30)
            Text(name)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview("图标演示") {
    NavigationStack {
        StringIconExtensionDemoView()
    }
}