// Preserve the original PDF's glyphs and layout, add blue linked text, and retain
// its existing contact links. Uses native PDFKit and Core Graphics on macOS.
// Usage: swift scripts/style_professional_cv.swift ORIGINAL.pdf LINKS.json OUTPUT.pdf
import Foundation
import PDFKit
import AppKit

guard CommandLine.arguments.count == 4 else { fatalError("Expected original PDF, link map and output PDF") }
let args = CommandLine.arguments
let input = URL(fileURLWithPath: args[1])
let output = URL(fileURLWithPath: args[3])
guard let pdf = PDFDocument(url: input), let source = CGPDFDocument(input as CFURL) else { fatalError("Cannot read original PDF") }
let links = try JSONDecoder().decode([String: String].self, from: Data(contentsOf: URL(fileURLWithPath: args[2])))
var additions: [Int: [(CGRect, URL)]] = [:]
for (label, address) in links.sorted(by: { $0.key < $1.key }) {
    for selection in pdf.findString(label, withOptions: []) {
        for line in selection.selectionsByLine() {
            for page in line.pages {
                additions[pdf.index(for: page), default: []].append((line.bounds(for: page), URL(string: address)!))
            }
        }
    }
}
var mediaBox = source.page(at: 1)!.getBoxRect(.mediaBox)
let metadata: [CFString: Any] = [kCGPDFContextTitle: "Khadijah Aamir Chaudhry — Professional CV", kCGPDFContextAuthor: "Khadijah Aamir Chaudhry"]
guard let context = CGContext(output as CFURL, mediaBox: &mediaBox, metadata as CFDictionary) else { fatalError("Cannot create PDF") }
for i in 0..<pdf.pageCount {
    let page = pdf.page(at: i)!
    let original = source.page(at: i + 1)!
    context.beginPDFPage(nil)
    context.setFillColor(CGColor(gray: 1, alpha: 1))
    context.fill(mediaBox)
    context.drawPDFPage(original)
    // Screen blending changes dark glyphs to blue while leaving white space
    // white. It preserves the original embedded fonts, positions and text.
    context.saveGState()
    context.setBlendMode(.screen)
    context.setFillColor(CGColor(red: 0, green: 59.0 / 224.0, blue: 99.0 / 220.0, alpha: 1))
    for (bounds, _) in additions[i, default: []] { context.fill(bounds) }
    context.restoreGState()
    for annotation in page.annotations {
        if let url = annotation.url { context.setURL(url as CFURL, for: annotation.bounds) }
    }
    for (bounds, url) in additions[i, default: []] { context.setURL(url as CFURL, for: bounds) }
    context.endPDFPage()
}
context.closePDF()
print("Preserved \(pdf.pageCount) original page(s). Added \(additions.values.reduce(0) { $0 + $1.count }) blue links.")
