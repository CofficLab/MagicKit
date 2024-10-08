import SwiftUI

#if os(macOS) || os(iOS)
struct MenuTile: View {
    var title: String = "[无标题]"
    var dragging: Bool = false
    var trailing: String = ""
    var isFolder: Bool = false
    var level: Int = 0
    var forceIcon: String = ""
    var loading: Bool = false

    @Binding var deleting: Bool
    var selected: Bool
    @Binding var collapsed: Bool
    var clicked: () -> Void = {}

    @State private var indicatorHovered: Bool = false
    @State private var hovered: Bool = false

    private var icon: some View {
        #if os(macOS)
            var color = Color(.controlAccentColor)
        #endif

        #if os(iOS)
            var color = Color(.blue)
        #endif

        if selected == true {
            color = Color(.white)
        }

        var systemName = isFolder ? "folder" : "doc.text"
        if !forceIcon.isEmpty {
            systemName = forceIcon
        }
        return HStack {
            Image(systemName: systemName)
                .resizable()
                .frame(width: isFolder ? 14 : 12, height: isFolder ? 12 : 15)
                .foregroundColor(color)
                .padding(.trailing, isFolder ? 0 : 2)
        }
    }

    // MARK: 计算背景色

    private var background: some View {
        if dragging {
            return Color.white.opacity(0.5)
        }

        if selected {
            #if os(macOS)
                return Color(.controlAccentColor).opacity(0.8)
            #endif

            #if os(iOS)
                return Color(.blue).opacity(0.8)
            #endif
        }

        if deleting == true {
            return Color(.gray).opacity(0.4)
        }

        #if os(macOS)
            if hovered {
                return Color(.controlAccentColor).opacity(0.1)
            }
        #endif

        return Color.clear
    }

    private var foregroundColor: Color {
        selected == true ? Color.white : Color.primary
    }

    var body: some View {
        ZStack {
            background

            HStack(spacing: 2) {
                Image(systemName: collapsed ? "chevron.forward" : "chevron.down")
                    .frame(width: 4, height: 4)
                    .foregroundColor(foregroundColor)
                    .onTapGesture { collapsed.toggle() }
                    .opacity(isFolder ? 1 : 0)
                    .onHover { hovering in
                        indicatorHovered = hovering
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
                    .cornerRadius(4)
                    .background(getIndicatorBackground())

                icon

                Text(title)
                    .foregroundColor(foregroundColor)

                Spacer()

                Text(trailing)
                    .font(.footnote)
                    .foregroundColor(foregroundColor)
                    .opacity(isFolder ? 1 : 0)

                if deleting || loading {
                    ProgressView().controlSize(.small)
                }
            }
            .onHover(perform: { v in
                hovered = v
            })
            .padding(.vertical, 4)
            .padding(.trailing, 12)
            .padding(.leading, 4 * CGFloat(level))
            .contentShape(Rectangle())
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
        .onTapGesture(count: 2) {
            collapsed.toggle()
            clicked()
        }

        // MARK: 单击事件

        .onTapGesture(count: 1) {
            clicked()
        }
        .cornerRadius(4)
        #if os(macOS)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(hovered ? Color(.controlAccentColor).opacity(0) : Color.clear, lineWidth: 1)
            )
        #endif
    }

    private func getIndicatorBackground() -> some ShapeStyle {
        if selected && indicatorHovered {
            return Color.gray.opacity(0.7)
        }

        if indicatorHovered {
            return Color.gray.opacity(0.2)
        }

        return Color.clear
    }
}

struct MenuTile_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            MenuTile(
                title: "普通",
                dragging: false,
                trailing: "",
                isFolder: false,
                deleting: Binding.constant(false),
                selected: false,
                collapsed: Binding.constant(false)
            )
            MenuTile(
                title: "普通删除中",
                dragging: false,
                deleting: Binding.constant(true),
                selected: false,
                collapsed: Binding.constant(true)
            )
            MenuTile(
                title: "普通加载中",
                dragging: false,
                loading: true,
                deleting: Binding.constant(false), selected: false,
                collapsed: Binding.constant(true)
            )
            MenuTile(
                title: "普通目录",
                dragging: false,
                isFolder: true,
                deleting: Binding.constant(false),
                selected: false,
                collapsed: Binding.constant(true)
            )
            MenuTile(
                title: "选中目录",
                dragging: false,
                isFolder: true,
                deleting: Binding.constant(false),
                selected: false,
                collapsed: Binding.constant(false)
            )
            MenuTile(
                title: "普通带尾部",
                dragging: false,
                trailing: "9",
                deleting: Binding.constant(false),
                selected: false,
                collapsed: Binding.constant(false)
            )
            MenuTile(
                title: "选中",
                dragging: false,
                deleting: Binding.constant(false),
                selected: false,
                collapsed: Binding.constant(false)
            )
            MenuTile(
                title: "展开",
                dragging: false,
                deleting: Binding.constant(false),
                selected: false,
                collapsed: Binding.constant(false)
            )
            MenuTile(
                title: "选中带尾部",
                dragging: false,
                trailing: "89",
                deleting: Binding.constant(false),
                selected: false,
                collapsed: Binding.constant(false)
            )
            MenuTile(
                title: "普通",
                dragging: false,
                trailing: "",
                isFolder: false,
                deleting: Binding.constant(false),
                selected: false,
                collapsed: Binding.constant(false)
            )
            MenuTile(
                title: "选中展开",
                dragging: false,
                deleting: Binding.constant(false),
                selected: false,
                collapsed: Binding.constant(false)
            )
        }
        .frame(width: 300)
        .padding(.all, 8)
    }
}
#endif
