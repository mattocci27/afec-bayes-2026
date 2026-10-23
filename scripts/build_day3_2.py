"""Build the extra computing session and its self-contained participant Project."""

import argparse
from pathlib import Path
import re
import subprocess
import tempfile
import zipfile


ROOT = Path(__file__).resolve().parent.parent
SESSION = ROOT / "day3-2"


def build(package_only=False):
    if not package_only:
        # Reuse the established solution-removal implementation; do not edit
        # the generated student QMD or broaden the existing Day 1-3 builders.
        subprocess.run([
            "Rscript", "--vanilla", "-e",
            'source("R/classroom_materials.R"); '
            'writeLines(student_source(readLines("day3-2/exercise.qmd")), '
            '"day3-2/exercise-student.qmd")'
        ], cwd=ROOT, check=True)
        text = (SESSION / "exercise.qmd").read_text()
        chunks = dict(re.findall(
            r"```\{r ([\w-]+)[^\n]*\}\n(.*?)\n```", text, re.S
        ))
        labels = ["location", "import-data", "inspect-column", "diameter-plot"]
        sections = [
            "# AFEC Day 3-2: run in the prepared RStudio Project.\n"
            "# Each row follows one fictional seedling over one interval.\n"
            "# diameter_mm: initial stem diameter (mm); survived: TRUE/FALSE/NA.\n"
            "# Read the data dictionary in README.md. No packages needed.\n"
            "# Run sections from the top; saving this script does not run it.\n"
            "# Generated from day3-2/exercise.qmd; edit that source to revise.\n"
        ]
        for index, label in enumerate(labels, 1):
            sections.append(f"# {index}. {label}\n{chunks[label]}\n")
        (SESSION / "project/R/inspect_seedlings.R").write_text("\n".join(sections))
        for path in [
            "slides.qmd", "exercise.qmd", "exercise-student.qmd",
            "instructor-notes.qmd", "project/report.qmd"
        ]:
            subprocess.run(["quarto", "render", str(SESSION / path)],
                           cwd=ROOT, check=True)

    # An explicit allowlist keeps planning notes, instructor answers and local
    # RStudio state out of the participant archive.
    files = {
        name: SESSION / "project" / name for name in [
            "AFEC-R-foundations.Rproj", "README.md", "data/seedlings.csv",
            "R/inspect_seedlings.R", "report.qmd", "report.html"
        ]
    }
    files.update({
        "slides.html": SESSION / "slides.html",
        "exercise.html": SESSION / "exercise-student.html",
    })
    for path in files.values():
        if not path.is_file():
            raise SystemExit(f"Missing build output: {path}")
    for source, output in [
        (SESSION / "slides.qmd", files["slides.html"]),
        (SESSION / "session.css", files["slides.html"]),
        (SESSION / "exercise.qmd", files["exercise.html"]),
        (SESSION / "project/report.qmd", files["report.html"]),
        (SESSION / "project/data/seedlings.csv", files["report.html"]),
        (SESSION / "project/data/seedlings.csv", files["exercise.html"]),
        (SESSION / "project/data/seedlings.csv", files["slides.html"]),
    ]:
        if output.stat().st_mtime < source.stat().st_mtime:
            raise SystemExit(f"Stale HTML: rebuild with make day3-2 ({output})")
    student = files["exercise.html"].read_text()
    if "Instructor interpretation" in student or "instructor-notes.html" in student:
        raise SystemExit("Instructor material in student HTML")
    # Reuse the existing offline-resource/link check on the exact package tree.
    from build_day1_package import check_links
    with tempfile.TemporaryDirectory(prefix="afec-day3-2-package-") as directory:
        stage = Path(directory) / "AFEC-R-foundations"
        for name, path in files.items():
            target = stage / name
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(path.read_bytes())
        check_links(stage)
        archive = ROOT / "dist/afec-day3-2-materials.zip"
        archive.parent.mkdir(exist_ok=True)
        with zipfile.ZipFile(archive, "w", zipfile.ZIP_DEFLATED) as package:
            for path in sorted(stage.rglob("*")):
                if path.is_file():
                    package.write(path, path.relative_to(stage.parent))
    print(f"Participant archive: {archive}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--package-only", action="store_true")
    args = parser.parse_args()
    build(args.package_only)
