# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Quarto-based lecture slide deck for a Statistics II / Data Visualization course (IKT2010). It produces a RevealJS presentation teaching ggplot2 to students, published via GitHub Pages.

- **Primary source**: `slides.qmd` — the single RevealJS presentation file
- **Config**: `_quarto.yml` — sets project type as `website`, output dir as `docs/`, and navbar
- **Styles**: `styles.css` — custom CSS for the RevealJS theme (font sizes, `.small-slide` class, `.red-text` class, code block sizing)
- **Data**: loaded at runtime from a remote GitHub URL (`raw.githubusercontent.com/mucahitzor/IKT2010/refs/heads/main/data/earnings.csv`)
- **Images**: stored under `pics/` (not tracked in git output) and `pics/memes/`
- **Output**: rendered to `docs/` for GitHub Pages hosting

## Commands

**Render the full site** (renders slides and copies output to `docs/`):
```bash
quarto render
```

**Preview with live reload** (opens browser, re-renders on save):
```bash
quarto preview
```

**Render a single file**:
```bash
quarto render slides.qmd
```

## Architecture

`_quarto.yml` configures this as a `website` project so that `quarto render` handles the `docs/` output directory and navbar automatically. The single content file `slides.qmd` uses `format: revealjs` in its own YAML front matter (overriding the site-level `format: html`).

Slide deck conventions in `slides.qmd`:
- Section headers (`#`) create title slides / section breaks
- `##` headers create individual slides
- `.small-slide` class on slides reduces font size to 0.55em (defined in `styles.css`)
- `.red-text` inline class highlights text in red
- `::: fragment` divs make content appear incrementally (set globally via `incremental: true`)
- Code chunks use `#| echo: true/false`, `#| eval: true/false`, `#| code-line-numbers` options
- Code annotations use `#| code-annotations: hover` with numbered callouts (`# <1>`, `# <2>`)

The `.quarto/` directory contains freeze cache and site_libs; these are auto-generated and should not be edited manually. The `docs/` directory is the rendered output committed to git for GitHub Pages.
