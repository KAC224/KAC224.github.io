// Add link annotations to the original PDF without reflowing or redrawing it.
// Usage: swift scripts/link_original_cv.swift INPUT.pdf LINKS.json OUTPUT.pdf
// Or: swift scripts/link_original_cv.swift --normalize INPUT.pdf OUTPUT.pdf
import Foundation
import PDFKit
import AppKit

guard CommandLine.arguments.count == 4 else {
    fatalError("Expected input PDF, link map JSON, and output PDF paths")
}
let args = CommandLine.arguments
let normalizeOnly = args[1] == "--normalize"
let input = URL(fileURLWithPath: normalizeOnly ? args[2] : args[1])
let output = URL(fileURLWithPath: args[3])
guard let document = PDFDocument(url: input) else { fatalError("Cannot read input PDF") }
let links: [String: String]
if normalizeOnly {
    links = [:]
} else {
    let data = try Data(contentsOf: URL(fileURLWithPath: args[2]))
    links = try JSONDecoder().decode([String: String].self, from: data)
}
var added = 0
for (label, address) in links.sorted(by: { $0.key < $1.key }) {
    for selection in document.findString(label, withOptions: []) {
        for line in selection.selectionsByLine() {
            for page in line.pages {
                let annotation = PDFAnnotation(bounds: line.bounds(for: page), forType: .link, withProperties: nil)
                annotation.url = URL(string: address)
                let border = PDFBorder()
                border.lineWidth = 0
                annotation.border = border
                annotation.color = .clear
                page.addAnnotation(annotation)
                added += 1
            }
        }
    }
}
// Pages percent-encodes URL fragments during Word-to-PDF export.
for i in 0..<document.pageCount {
    guard let page = document.page(at: i) else { continue }
    for annotation in page.annotations {
        if let address = annotation.url?.absoluteString, address.contains("%23") {
            annotation.url = URL(string: address.replacingOccurrences(of: "%23", with: "#"))
        }
    }
}
if !normalizeOnly {
    var attributes = document.documentAttributes ?? [:]
    attributes[PDFDocumentAttribute.titleAttribute] = "Khadijah Aamir Chaudhry — Professional CV"
    document.documentAttributes = attributes
}
guard document.write(to: output) else { fatalError("Cannot write output PDF") }
print("Added \(added) links. Kept \(document.pageCount) original page(s).")
