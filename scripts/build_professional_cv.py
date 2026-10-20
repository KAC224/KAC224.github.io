"""Color linked glyphs in the original PDF without changing fonts or spacing.

Requires pypdf 6.21.1, macOS PDFKit, and Swift. Run from any directory.
"""
import json
import subprocess
import tempfile
from pathlib import Path

from pypdf import PdfReader, PdfWriter
from pypdf._cmap import get_encoding
from pypdf.generic import ArrayObject, ByteStringObject, FloatObject, TextStringObject

ROOT = Path(__file__).resolve().parents[1]
CV = ROOT / "cv"
NAME = "Khadijah_Aamir_Chaudhry"
BLUE = (23 / 255, 90 / 255, 134 / 255)


def raw_bytes(value):
    if isinstance(value, TextStringObject):
        return value.original_bytes
    return bytes(value)


def color_links(page, labels):
    """Split text drawing arrays only at color boundaries, retaining kerning."""
    stream = page.get_contents()
    encodings = {
        name: get_encoding(font.get_object())
        for name, font in page["/Resources"]["/Font"].items()
    }
    text, positions = [], []
    font_name = None
    for op_index, (args, op) in enumerate(stream.operations):
        if op == b"Tf":
            font_name = args[0]
        elif op == b"BT":
            text.append("\n")
            positions.append(None)
        elif op in (b"Tj", b"TJ"):
            encoding, cmap = encodings[font_name]
            items = args[0] if op == b"TJ" else args
            for item_index, item in enumerate(items):
                if not isinstance(item, (TextStringObject, ByteStringObject)):
                    continue
                for byte_index, byte in enumerate(raw_bytes(item)):
                    char = encoding[byte] if isinstance(encoding, dict) else bytes([byte]).decode(encoding)
                    decoded = cmap.get(char, char)
                    text.extend(decoded)
                    positions.extend([(op_index, item_index, byte_index)] * len(decoded))
    text = "".join(text)
    linked = set()
    for label in labels:
        start = 0
        while (start := text.find(label, start)) >= 0:
            linked.update(positions[start:start + len(label)])
            start += len(label)

    result = []
    color = (0, 0, 0)
    stack = []
    for op_index, (args, op) in enumerate(stream.operations):
        if op == b"q":
            stack.append(color)
        elif op == b"Q":
            color = stack.pop()
        elif op == b"sc":
            color = tuple(args)
        if op not in (b"Tj", b"TJ"):
            result.append((args, op))
            continue
        items = args[0] if op == b"TJ" else args
        groups = []
        current_color = color
        current_items = []
        for item_index, item in enumerate(items):
            if not isinstance(item, (TextStringObject, ByteStringObject)):
                current_items.append(item)
                continue
            for byte_index, byte in enumerate(raw_bytes(item)):
                desired = BLUE if (op_index, item_index, byte_index) in linked else color
                if desired != current_color:
                    if current_items:
                        groups.append((current_color, current_items))
                    current_items = []
                    current_color = desired
                # Keep raw font codes. Re-encoding Unicode would change glyphs.
                if current_items and isinstance(current_items[-1], ByteStringObject):
                    current_items[-1] = ByteStringObject(current_items[-1] + bytes([byte]))
                else:
                    current_items.append(ByteStringObject(bytes([byte])))
        if current_items:
            groups.append((current_color, current_items))
        for group_color, group_items in groups:
            result.append(([FloatObject(c) for c in group_color], b"sc"))
            result.append(([ArrayObject(group_items)], b"TJ"))
        result.append(([FloatObject(c) for c in color], b"sc"))
    stream.operations = result
    page.replace_contents(stream)


def main():
    links_file = ROOT / "scripts/cv-links.json"
    links = json.loads(links_file.read_text())
    reader = PdfReader(CV / "archive" / f"{NAME}_Original_CV.pdf")
    writer = PdfWriter()
    for source_page in reader.pages:
        page = writer.add_page(source_page)
        color_links(page, links)
    with tempfile.TemporaryDirectory(prefix="professional-cv-") as folder:
        colored = Path(folder) / "colored.pdf"
        writer.write(colored)
        subprocess.run([
            "swift", str(ROOT / "scripts/style_professional_cv.swift"),
            str(colored), str(links_file), str(CV / f"{NAME}_Professional_CV.pdf"),
        ], check=True)


if __name__ == "__main__":
    main()
