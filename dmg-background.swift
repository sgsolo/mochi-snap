import AppKit

let outputDirectory = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
let size = NSSize(width: 640, height: 280)
let center = NSPoint(x: size.width / 2, y: size.height - 116)
let gray = NSColor(srgbRed: 0.40, green: 0.40, blue: 0.43, alpha: 1)
let configuration = NSImage.SymbolConfiguration(pointSize: 52, weight: .regular)
    .applying(.init(paletteColors: [gray]))
let arrow = NSImage(systemSymbolName: "arrow.right", accessibilityDescription: nil)!
    .withSymbolConfiguration(configuration)!

for scale in 1...2 {
    let bitmap = NSBitmapImageRep(
        bitmapDataPlanes: nil, pixelsWide: Int(size.width) * scale, pixelsHigh: Int(size.height) * scale,
        bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
        colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0
    )!
    let context = NSGraphicsContext(bitmapImageRep: bitmap)!

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = context
    context.cgContext.scaleBy(x: CGFloat(scale), y: CGFloat(scale))
    NSColor.white.setFill()
    NSBezierPath(rect: NSRect(origin: .zero, size: size)).fill()
    arrow.draw(at: NSPoint(x: center.x - arrow.size.width / 2, y: center.y - arrow.size.height / 2),
               from: .zero, operation: .sourceOver, fraction: 1)
    NSGraphicsContext.restoreGraphicsState()

    let filename = scale == 1 ? "dmg-background.png" : "dmg-background@2x.png"
    try bitmap.representation(using: .png, properties: [:])!
        .write(to: outputDirectory.appendingPathComponent(filename))
}
