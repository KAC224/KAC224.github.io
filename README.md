# Khadijah Aamir Chaudhry — Portfolio

Personal portfolio hosted at [kac224.github.io](https://kac224.github.io/).

The site uses HTML, CSS, and JavaScript. Open `index.html` locally to edit it; changes pushed to `main` are published through GitHub Pages. The linked CV and project write-ups are in `cv/` and `assets/`.

The CVs use the original Times New Roman Word layout. `cv/archive/Khadijah_Aamir_Chaudhry_Original_CV.pdf` and the matching Word file preserve the one-page website CV from before the redesign.

- The professional CV preserves the original one-page A4 layout with blue clickable links.
- The academic CV expands the same layout with more spacing, two bullets per experience and project, and additional projects under the same Projects section.
- The older June/August academic résumé is retained separately in `cv/archive/`.

Editable Word files are included alongside both published PDFs.

## Folder layout

- `index.html`, `styles.css`, `script.js`: website.
- `assets/`: images and project write-ups used by the site.
- `cv/`: current academic and professional PDFs and editable Word files.
- `cv/archive/`: preserved original CVs.
- `scripts/`: CV source generation, PDF generation, and link destinations.
- `.local/` (ignored by Git): source images, the spacing reference PDF, and earlier project notes.

## Updating the CVs

Install `python-docx` and `pypdf==6.21.1` into a local Python environment. PDF export also requires macOS, Swift, and Pages Creator Studio.

1. Run `python scripts/build_cv_sources.py` to build both Word files from the preserved original and update `scripts/cv-links.json`.
2. Export the academic file with `osascript scripts/export_cv.applescript`, passing the absolute Word and PDF paths.
3. Run `python scripts/build_professional_cv.py` to build the professional PDF. It sets linked glyphs to `#175A86`, matching the academic CV, and adds link annotations using the Swift helper. The original fonts, glyph positions, and kerning are retained.

Both CVs link to external destinations or project write-ups, with no links back to portfolio sections. The website uses clean PDF filenames without cache tags in the URLs.
