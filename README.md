# Khadijah Aamir Chaudhry — Portfolio

Personal portfolio hosted at [kac224.github.io](https://kac224.github.io/).

The site uses HTML, CSS, and JavaScript. Open `index.html` locally to edit it; changes pushed to `main` are published through GitHub Pages. The linked CV and project write-ups are in `cv/` and `assets/`.

The CVs use the original Times New Roman Word layout. `cv/Khadijah_Aamir_Chaudhry_Original_CV.pdf` and the matching Word file preserve the one-page website CV from before the redesign.

- The professional CV preserves the original one-page A4 layout with blue clickable links.
- The academic CV expands the same layout with more spacing, two bullets per experience and project, and additional projects under the same Projects section.
- The older June/August academic résumé is retained separately in `cv/archive/`.

Editable Word files are included alongside both PDFs. The LaTeX redesign has been removed.

`scripts/build_cv_sources.py` builds both Word files from the preserved original. Export the academic file with `scripts/export_cv.applescript`, passing the absolute Word and PDF paths. Build the professional PDF with `scripts/style_professional_cv.swift`, passing the original PDF, `scripts/cv-links.json`, and the output PDF. This preserves its original glyphs and layout while making linked text blue. Both CVs link to external destinations or project write-ups, with no links back to portfolio sections.
