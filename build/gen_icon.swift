import AppKit
import Foundation

// MARK: - 常量
let SS: CGFloat = 1024
let SSP = 1024
let corner = CGFloat((Double(SSP) * 0.223).rounded())   // macOS 圆角半径

let bgTop    = NSColor(red: 0x54/255, green: 0xAB/255, blue: 0xFF/255, alpha: 1) // #54ABFF
let bgBottom = NSColor(red: 0x2B/255, green: 0x5F/255, blue: 0xE8/255, alpha: 1) // #2B5FE8
let green    = NSColor(red: 0x34/255, green: 0xC7/255, blue: 0x59/255, alpha: 1) // #34C759
let bar1     = NSColor(red: 0xA9/255, green: 0xB4/255, blue: 0xC6/255, alpha: 1)
let bar2     = NSColor(red: 0xCA/255, green: 0xD2/255, blue: 0xE0/255, alpha: 1)

// MARK: - 带 alpha 的位图上下文工具
func newRep(_ w: Int, _ h: Int) -> NSBitmapImageRep {
    NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: w, pixelsHigh: h,
                     bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                     colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
}
func begin(_ rep: NSBitmapImageRep) {
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    NSGraphicsContext.current?.imageInterpolation = .high
}
func end() { NSGraphicsContext.restoreGraphicsState() }

// MARK: - 绘制主图标（1024，圆角遮罩 + 透明外角）
func drawMaster(_ ctx: CGContext) {
    let full = NSRect(x: 0, y: 0, width: SS, height: SS)
    NSBezierPath(roundedRect: full, xRadius: corner, yRadius: corner).addClip()

    // 对角渐变底
    NSGradient(starting: bgTop, ending: bgBottom)?
        .draw(from: NSPoint(x: 0, y: SS), to: NSPoint(x: SS, y: 0), options: [])

    // 顶部高光（全幅垂直渐变，避免出现矩形接缝）
    NSGradient(colors: [NSColor.white.withAlphaComponent(0.26),
                        NSColor.white.withAlphaComponent(0.0)])?
        .draw(from: NSPoint(x: 0, y: SS), to: NSPoint(x: 0, y: SS*0.46), options: [])

    // 底部加深，增强纵深
    NSGradient(colors: [NSColor(red:0x1B/255,green:0x3F/255,blue:0xB8/255,alpha:0.0),
                        NSColor(red:0x16/255,green:0x31/255,blue:0x96/255,alpha:0.30)])?
        .draw(from: NSPoint(x: 0, y: SS*0.52), to: NSPoint(x: 0, y: 0), options: [])

    // Toast 胶囊
    let cw: CGFloat = 664, ch: CGFloat = 234
    let cap = NSRect(x: (SS-cw)/2, y: (SS-ch)/2, width: cw, height: ch)
    let capPath = NSBezierPath(roundedRect: cap, xRadius: ch/2, yRadius: ch/2)

    ctx.saveGState()
    let shadow = NSShadow()
    shadow.shadowColor = NSColor.black.withAlphaComponent(0.32)
    shadow.shadowOffset = NSSize(width: 0, height: -24)
    shadow.shadowBlurRadius = 40
    shadow.set()
    NSColor.white.setFill()
    capPath.fill()
    ctx.restoreGState()

    // 绿色对勾圆
    let cx = cap.minX + 116, cy = SS/2, r: CGFloat = 60
    green.setFill()
    NSBezierPath(ovalIn: NSRect(x: cx-r, y: cy-r, width: r*2, height: r*2)).fill()

    // 白色对勾（左下短撇 → 底部转折 → 右上长划）
    let chk = NSBezierPath()
    chk.move(to: NSPoint(x: cx-32, y: cy+3))
    chk.line(to: NSPoint(x: cx-6,  y: cy-20))
    chk.line(to: NSPoint(x: cx+34, y: cy+25))
    chk.lineWidth = 15
    chk.lineCapStyle = .round
    chk.lineJoinStyle = .round
    NSColor.white.setStroke()
    chk.stroke()

    // 两道灰条（示意「已复制 · 文本」）
    let bx = cx + r + 60
    bar1.setFill()
    NSBezierPath(roundedRect: NSRect(x: bx, y: cy+8,      width: 340, height: 32),
                 xRadius: 16, yRadius: 16).fill()
    bar2.setFill()
    NSBezierPath(roundedRect: NSRect(x: bx, y: cy-38,     width: 220, height: 26),
                 xRadius: 13, yRadius: 13).fill()
}

print("生成 iconset:")
let root = FileManager.default.currentDirectoryPath
let iconset = "\(root)/build/icons.iconset"
let pv = "\(root)/build/preview"
try! FileManager.default.createDirectory(atPath: iconset, withIntermediateDirectories: true)
try! FileManager.default.createDirectory(atPath: pv, withIntermediateDirectories: true)

// 主图（1024）
let masterRep = newRep(SSP, SSP)
begin(masterRep)
drawMaster(NSGraphicsContext.current!.cgContext)
end()
let master = NSImage(size: NSSize(width: SS, height: SS))
master.addRepresentation(masterRep)

func export(_ size: Int, _ path: String) {
    let rep = newRep(size, size)
    begin(rep)
    NSColor.clear.setFill()
    NSBezierPath(rect: NSRect(x: 0, y: 0, width: size, height: size)).fill()
    master.draw(in: NSRect(x: 0, y: 0, width: size, height: size),
                from: .zero, operation: .copy, fraction: 1)
    end()
    try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: path))
    print("  -> \(path)")
}

let specs: [(Int, String)] = [
    (16,  "icon_16x16.png"),      (32,  "icon_16x16@2x.png"),
    (32,  "icon_32x32.png"),      (64,  "icon_32x32@2x.png"),
    (128, "icon_128x128.png"),    (256, "icon_128x128@2x.png"),
    (256, "icon_256x256.png"),    (512, "icon_256x256@2x.png"),
    (512, "icon_512x512.png"),    (1024,"icon_512x512@2x.png"),
]
for (size, name) in specs { export(size, "\(iconset)/\(name)") }

// 预览图 + Dock 展示图
export(1024, "\(pv)/icon_1024.png")

let W = 1280, H = 800
let sRep = newRep(W, H)
begin(sRep)
NSGradient(colors: [NSColor(red:0xF3/255,green:0xF5/255,blue:0xF9/255,alpha:1),
                    NSColor(red:0xE2/255,green:0xE7/255,blue:0xF1/255,alpha:1)])?
    .draw(from: NSPoint(x:0,y:H), to: NSPoint(x:W,y:0), options: [])
let dockW: CGFloat = 780, dockH: CGFloat = 210
let dock = NSRect(x: (CGFloat(W) - dockW)/2, y: CGFloat(H)/2 - dockH/2 + 30,
                  width: dockW, height: dockH)
NSGraphicsContext.saveGraphicsState()
let dShadow = NSShadow()
dShadow.shadowColor = NSColor.black.withAlphaComponent(0.16)
dShadow.shadowOffset = NSSize(width: 0, height: -16)
dShadow.shadowBlurRadius = 44
dShadow.set()
NSColor(white: 0.97, alpha: 0.9).setFill()
NSBezierPath(roundedRect: dock, xRadius: 52, yRadius: 52).fill()
NSGraphicsContext.restoreGraphicsState()
let iconSize: CGFloat = 150
master.draw(in: NSRect(x: dock.minX + (dockW-iconSize)/2, y: dock.minY + (dockH-iconSize)/2,
                       width: iconSize, height: iconSize),
            from: .zero, operation: .copy, fraction: 1)

// 应用名
let label = NSAttributedString(string: "CopyToast", attributes: [
    .font: NSFont.systemFont(ofSize: 34, weight: .semibold),
    .foregroundColor: NSColor(white: 0.28, alpha: 1)])
let ls = label.size()
label.draw(at: NSPoint(x: (CGFloat(W)-ls.width)/2, y: 96))
end()
try! sRep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: "\(pv)/showcase.png"))
print("  -> \(pv)/showcase.png")
print("完成。")
