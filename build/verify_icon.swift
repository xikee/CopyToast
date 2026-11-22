import AppKit
import Foundation

let appPath = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "/Applications/CopyToast.app"
let out = "\(FileManager.default.currentDirectoryPath)/build/preview/finder_icon.png"
let size = 512

let icon = NSWorkspace.shared.icon(forFile: appPath)
icon.size = NSSize(width: size, height: size)

let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: size, pixelsHigh: size,
                           bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                           colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
NSGraphicsContext.current?.imageInterpolation = .high
NSColor.clear.setFill()
NSBezierPath(rect: NSRect(x: 0, y: 0, width: size, height: size)).fill()
icon.draw(in: NSRect(x: 0, y: 0, width: size, height: size))
NSGraphicsContext.restoreGraphicsState()
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: out))
print("系统渲染的 app 图标 -> \(out)")
