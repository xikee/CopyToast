import AppKit
import Foundation

let root = FileManager.default.currentDirectoryPath
let src = "\(root)/build/preview/icon_1024.png"
let out = "\(root)/build/preview/sizes.png"
let master = NSImage(contentsOfFile: src)!

let W = 600, H = 300
let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: W, pixelsHigh: H,
                           bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                           colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
NSGraphicsContext.current?.imageInterpolation = .high

NSColor(white: 0.99, alpha: 1).setFill()
NSBezierPath(rect: NSRect(x: 0, y: 0, width: W, height: H)).fill()

let baseline: CGFloat = 130
var x: CGFloat = 56
for s in [128, 64, 32, 16] {
    let cs = CGFloat(s)
    master.draw(in: NSRect(x: x, y: baseline, width: cs, height: cs),
                from: .zero, operation: .copy, fraction: 1)
    let t = NSAttributedString(string: "\(s)px", attributes: [
        .font: NSFont.monospacedDigitSystemFont(ofSize: 13, weight: .regular),
        .foregroundColor: NSColor(white: 0.45, alpha: 1)])
    let ts = t.size()
    t.draw(at: NSPoint(x: x + (cs - ts.width)/2, y: baseline - 30))
    x += cs + 62
}
NSGraphicsContext.restoreGraphicsState()
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: out))
print("多尺寸一览 -> \(out)")
