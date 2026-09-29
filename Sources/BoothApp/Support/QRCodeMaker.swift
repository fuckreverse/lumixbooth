import AppKit
import CoreImage

/// 二维码生成（CoreImage CIQRCodeGenerator，本地无需外网，SPEC §8）
enum QRCodeMaker {
    /// 生成像素边缘清晰的二维码 NSImage（仿射放大而非重采样，保证扫码可靠）
    static func image(for text: String, pixels: CGFloat = 320) -> NSImage? {
        guard let data = text.data(using: .utf8),
              let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")
        guard let output = filter.outputImage, output.extent.width > 0 else { return nil }
        let scale = pixels / output.extent.width
        let scaled = output.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        let rep = NSBitmapImageRep(ciImage: scaled)
        let image = NSImage(size: rep.size)
        image.addRepresentation(rep)
        return image
    }
}
