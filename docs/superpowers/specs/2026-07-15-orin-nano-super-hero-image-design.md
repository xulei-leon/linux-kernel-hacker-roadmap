# Orin Nano Super Hero Image Design

## Goal

Add a recognizable NVIDIA Jetson Orin Nano Super Developer Kit image to the GitHub Pages home page without changing the roadmap content or navigation hierarchy.

## Source and asset handling

- Use the official 1200 × 630 product image published on NVIDIA's Jetson Orin Nano Super Developer Kit page.
- Download the image into `public/images/` so the deployed page does not depend on a third-party request at render time.
- Use a descriptive, English file name and preserve the original JPEG format to avoid unnecessary recompression.

## Home-page presentation

- Add the image through VitePress's native `hero.image` frontmatter field in `index.md`.
- Display it to the right of the existing hero copy on wide screens and below the copy in the standard responsive VitePress layout.
- Provide English alternative text that identifies the NVIDIA Jetson Orin Nano Super Developer Kit (8GB).
- Add only the focused CSS needed for a restrained border radius, border, shadow, and responsive sizing.
- Preserve the existing hero title, tagline, actions, feature cards, and content sections.

## Verification

- Run the VitePress production build.
- Inspect the rendered home page at desktop and mobile widths, including light and dark themes.
- Confirm that the image is loaded from the configured GitHub Pages base path and that its alternative text is present.
- Run `git diff --check`.

## Out of scope

- Redesigning the home page.
- Adding image galleries, product specifications, or promotional copy.
- Changing the roadmap's evidence boundaries or platform claims.
