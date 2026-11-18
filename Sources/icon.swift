import AppKit

func appIcon(size: Int) -> Data {
    let bitmap = NSBitmapImageRep(
        bitmapDataPlanes: nil, pixelsWide: size, pixelsHigh: size,
        bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
        colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0
    )!
    let context = NSGraphicsContext(bitmapImageRep: bitmap)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = context
    let transform = NSAffineTransform()
    transform.scale(by: CGFloat(size) / 1_024)
    transform.concat()

    let base = NSBezierPath(roundedRect: NSRect(x: 64, y: 64, width: 896, height: 896),
                            xRadius: 204, yRadius: 204)
    NSGradient(starting: NSColor(srgbRed: 0.84, green: 0.76, blue: 1, alpha: 1),
               ending: NSColor(srgbRed: 1, green: 0.86, blue: 0.86, alpha: 1))!
        .draw(in: base, angle: 70)

    let shadow = NSShadow()
    shadow.shadowColor = NSColor(srgbRed: 0.38, green: 0.24, blue: 0.53, alpha: 0.16)
    shadow.shadowBlurRadius = 24
    shadow.shadowOffset = NSSize(width: 0, height: -18)
    NSGraphicsContext.saveGraphicsState()
    shadow.set()
    NSColor(srgbRed: 1, green: 0.98, blue: 0.96, alpha: 1).setFill()
    NSBezierPath(roundedRect: NSRect(x: 202, y: 265, width: 620, height: 454),
                 xRadius: 126, yRadius: 126).fill()
    NSGraphicsContext.restoreGraphicsState()
    NSColor(srgbRed: 1, green: 0.98, blue: 0.96, alpha: 1).setFill()
    NSBezierPath(roundedRect: NSRect(x: 348, y: 652, width: 180, height: 112),
                 xRadius: 38, yRadius: 38).fill()

    NSColor(srgbRed: 0.77, green: 0.67, blue: 0.96, alpha: 1).setFill()
    NSBezierPath(ovalIn: NSRect(x: 325, y: 330, width: 310, height: 310)).fill()
    NSColor(srgbRed: 0.92, green: 0.87, blue: 1, alpha: 1).setFill()
    NSBezierPath(ovalIn: NSRect(x: 354, y: 359, width: 252, height: 252)).fill()

    let ink = NSColor(srgbRed: 0.28, green: 0.22, blue: 0.38, alpha: 1)
    ink.setFill()
    NSBezierPath(roundedRect: NSRect(x: 422, y: 474, width: 20, height: 32), xRadius: 10, yRadius: 10).fill()
    NSBezierPath(roundedRect: NSRect(x: 522, y: 474, width: 20, height: 32), xRadius: 10, yRadius: 10).fill()
    let smile = NSBezierPath()
    smile.move(to: NSPoint(x: 456, y: 457))
    smile.curve(to: NSPoint(x: 506, y: 457), controlPoint1: NSPoint(x: 467, y: 437), controlPoint2: NSPoint(x: 495, y: 437))
    smile.lineWidth = 11
    smile.lineCapStyle = .round
    ink.setStroke()
    smile.stroke()
    NSColor(srgbRed: 1, green: 0.65, blue: 0.72, alpha: 0.95).setFill()
    NSBezierPath(ovalIn: NSRect(x: 390, y: 448, width: 35, height: 18)).fill()
    NSBezierPath(ovalIn: NSRect(x: 540, y: 448, width: 35, height: 18)).fill()
    NSColor(srgbRed: 0.71, green: 0.86, blue: 0.78, alpha: 1).setFill()
    NSBezierPath(roundedRect: NSRect(x: 672, y: 603, width: 78, height: 40), xRadius: 17, yRadius: 17).fill()

    // Four curved points make a small sparkle beside the camera.
    let sparkle = NSBezierPath()
    sparkle.move(to: NSPoint(x: 756, y: 832))
    sparkle.curve(to: NSPoint(x: 822, y: 766), controlPoint1: NSPoint(x: 767, y: 784), controlPoint2: NSPoint(x: 774, y: 778))
    sparkle.curve(to: NSPoint(x: 756, y: 700), controlPoint1: NSPoint(x: 774, y: 754), controlPoint2: NSPoint(x: 767, y: 748))
    sparkle.curve(to: NSPoint(x: 690, y: 766), controlPoint1: NSPoint(x: 745, y: 748), controlPoint2: NSPoint(x: 738, y: 754))
    sparkle.curve(to: NSPoint(x: 756, y: 832), controlPoint1: NSPoint(x: 738, y: 778), controlPoint2: NSPoint(x: 745, y: 784))
    NSColor.white.setFill()
    sparkle.fill()
    NSGraphicsContext.restoreGraphicsState()
    return bitmap.representation(using: .png, properties: [:])!
}

let folder = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
for size in [16, 32, 128, 256, 512] {
    try appIcon(size: size).write(to: folder.appendingPathComponent("icon_\(size)x\(size).png"))
    try appIcon(size: size * 2).write(to: folder.appendingPathComponent("icon_\(size)x\(size)@2x.png"))
}
