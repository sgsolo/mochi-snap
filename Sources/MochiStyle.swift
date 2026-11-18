import AppKit
import SwiftUI

@MainActor
enum MochiStyle {
    static let ink = NSColor(name: nil) { appearance in
        appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            ? NSColor(srgbRed: 0.95, green: 0.92, blue: 1, alpha: 1)
            : NSColor(srgbRed: 0.24, green: 0.19, blue: 0.34, alpha: 1)
    }
    static let surface = NSColor(name: nil) { appearance in
        appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            ? NSColor(srgbRed: 0.17, green: 0.15, blue: 0.22, alpha: 1)
            : NSColor(srgbRed: 0.99, green: 0.97, blue: 1, alpha: 1)
    }
    static let accent = NSColor(srgbRed: 0.63, green: 0.43, blue: 0.90, alpha: 1)
    static let blush = NSColor(srgbRed: 1, green: 0.81, blue: 0.82, alpha: 1)
    static let mint = NSColor(srgbRed: 0.75, green: 0.91, blue: 0.83, alpha: 1)
    static let lavender = NSColor(srgbRed: 0.86, green: 0.80, blue: 1, alpha: 1)

    static func roundedFont(_ size: CGFloat, weight: NSFont.Weight = .regular) -> NSFont {
        let font = NSFont.systemFont(ofSize: size, weight: weight)
        return font.fontDescriptor.withDesign(.rounded).map { NSFont(descriptor: $0, size: size)! } ?? font
    }

    static func style(_ window: NSWindow) {
        window.backgroundColor = surface
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
    }

    static func style(_ button: NSButton, primary: Bool = false) {
        button.bezelStyle = .rounded
        button.font = roundedFont(13, weight: .semibold)
        button.bezelColor = primary ? accent : lavender
        button.contentTintColor = primary ? .white : ink
    }
}

enum MochiAction {
    case screenshotArea, screenshotDisplay, recordArea, recordDisplay, stopRecording
    case settings, folder, permission, retryHotKey, quit
}

struct MochiDashboard: View {
    let recording: Bool
    let busyRecording: Bool
    let canCapture: Bool
    let hotKeyReady: Bool
    let hasPermission: Bool
    let loginEnabled: Bool
    let format: String
    let action: (MochiAction) -> Void
    let selectFormat: (String) -> Void
    let toggleLogin: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    private var dark: Bool { colorScheme == .dark }
    private var ink: Color { dark ? Color(red: 0.95, green: 0.92, blue: 1) : Color(red: 0.24, green: 0.19, blue: 0.34) }
    private var background: Color { dark ? Color(red: 0.17, green: 0.15, blue: 0.22) : Color(red: 0.99, green: 0.97, blue: 1) }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 11) {
                Image(nsImage: NSImage(named: "Mascot") ?? NSImage())
                    .resizable()
                    .frame(width: 58, height: 58)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Mochi Snap")
                        .font(.system(size: 23, weight: .heavy, design: .rounded))
                    Text("Лови момент. Делись вайбом.")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(ink.opacity(0.67))
                }
                Spacer(minLength: 0)
            }

            if recording {
                Button { action(.stopRecording) } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "stop.circle.fill").font(.system(size: 25))
                        VStack(alignment: .leading, spacing: 4) {
                            Text(busyRecording ? "Сохраняем видео…" : "Запись идёт")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                            Text(busyRecording ? "Ещё чуть-чуть" : "Нажми, чтобы остановить")
                                .font(.system(size: 12))
                        }
                        Spacer()
                    }
                    .padding(17)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(ink)
                    .background(Color(nsColor: MochiStyle.blush).opacity(dark ? 0.22 : 0.9), in: RoundedRectangle(cornerRadius: 20))
                }
                .buttonStyle(MochiCardStyle())
                .disabled(busyRecording)
            } else {
                Button { action(.screenshotArea) } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "viewfinder").font(.system(size: 29, weight: .medium))
                            .frame(width: 40)
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Лови скрин")
                                .font(.system(size: 19, weight: .heavy, design: .rounded))
                            Text("Выбери окно или область")
                                .font(.system(size: 11, weight: .medium))
                        }
                        Spacer(minLength: 0)
                        if hotKeyReady {
                            Text("⌘⇧A")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .padding(.horizontal, 8).padding(.vertical, 6)
                                .background(.white.opacity(0.4), in: Capsule())
                        }
                    }
                    .padding(16)
                    .foregroundStyle(Color(red: 0.24, green: 0.17, blue: 0.35))
                    .background(
                        LinearGradient(colors: [Color(nsColor: MochiStyle.lavender), Color(red: 0.98, green: 0.84, blue: 0.89)],
                                       startPoint: .topLeading, endPoint: .bottomTrailing),
                        in: RoundedRectangle(cornerRadius: 22)
                    )
                }
                .buttonStyle(MochiCardStyle())
                .disabled(!canCapture)
            }

            HStack(spacing: 10) {
                tile("Весь экран", detail: "Один клик — и готово", symbol: "rectangle.dashed",
                     tint: MochiStyle.mint, action: .screenshotDisplay, enabled: canCapture)
                tile("Запись", detail: "Область экрана", symbol: "record.circle",
                     tint: MochiStyle.blush, action: .recordArea, enabled: canCapture && !recording)
            }

            if !recording {
                Button { action(.recordDisplay) } label: {
                    HStack {
                        Image(systemName: "video")
                        Text("Записать весь экран")
                        Spacer()
                        Image(systemName: "arrow.up.right").font(.system(size: 10, weight: .bold))
                    }
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(ink.opacity(0.78))
                    .padding(.horizontal, 4)
                }
                .buttonStyle(.plain)
                .disabled(!canCapture)
            }

            if !hasPermission {
                Button { action(.permission) } label: {
                    HStack(alignment: .center, spacing: 10) {
                        Image(systemName: "hand.wave").font(.system(size: 18))
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Познакомимся с экраном?")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                            Text("Разреши захват в настройках macOS")
                                .font(.system(size: 10))
                        }
                        Spacer(minLength: 0)
                        Image(systemName: "chevron.right").font(.system(size: 10, weight: .semibold))
                    }
                    .padding(12)
                    .foregroundStyle(ink)
                    .background(ink.opacity(0.045), in: RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(MochiCardStyle())
            } else if !hotKeyReady {
                Button("⌘⇧A занято · Попробовать ещё раз") { action(.retryHotKey) }
                    .font(.system(size: 11))
                    .buttonStyle(.plain)
                    .foregroundStyle(ink.opacity(0.7))
            }

            VStack(spacing: 14) {
                HStack {
                    Label("Формат снимка", systemImage: "photo")
                    Spacer()
                    Menu {
                        ForEach(["PNG", "JPEG", "PDF"], id: \.self) { value in
                            Button {
                                selectFormat(value)
                            } label: {
                                if format == value { Label(value, systemImage: "checkmark") }
                                else { Text(value) }
                            }
                        }
                    } label: {
                        Text(format).fontWeight(.bold).frame(width: 46)
                    }
                    .fixedSize()
                }
                Toggle(isOn: Binding(get: { loginEnabled }, set: { _ in toggleLogin() })) {
                    Label("Встречать при входе", systemImage: "sun.max")
                }
                .toggleStyle(.switch)
                .controlSize(.small)
                HStack(spacing: 15) {
                    Button { action(.folder) } label: { Label("Мои файлы", systemImage: "folder") }
                    Spacer(minLength: 0)
                    Button { action(.settings) } label: { Image(systemName: "slider.horizontal.3") }
                        .help("Настройки")
                        .accessibilityLabel("Настройки")
                    Button { action(.quit) } label: { Image(systemName: "power") }
                        .help("Выйти из Mochi Snap")
                        .accessibilityLabel("Выйти")
                }
                .buttonStyle(.plain)
            }
            .font(.system(size: 12, weight: .medium, design: .rounded))
            .foregroundStyle(ink.opacity(0.8))
        }
        .padding(22)
        .frame(width: 370)
        .background(background)
        .tint(Color(nsColor: MochiStyle.accent))
    }

    private func tile(_ title: String, detail: String, symbol: String, tint: NSColor,
                      action value: MochiAction, enabled: Bool) -> some View {
        Button { action(value) } label: {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: symbol)
                    .font(.system(size: 22, weight: .medium))
                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(.system(size: 14, weight: .bold, design: .rounded))
                    Text(detail).font(.system(size: 10, weight: .medium))
                        .foregroundStyle(ink.opacity(0.65))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(15)
            .foregroundStyle(ink)
            .background(Color(nsColor: tint).opacity(dark ? 0.15 : 0.6), in: RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(MochiCardStyle())
        .disabled(!enabled)
    }
}

private struct MochiCardStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.8 : 1)
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.98 : 1)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
