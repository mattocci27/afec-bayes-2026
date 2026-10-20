"""Stage the existing participant package for GitHub Pages; never run inference."""

import argparse
from pathlib import Path, PurePosixPath
import shutil
import zipfile


def build(output: Path) -> None:
    root = Path(__file__).resolve().parent.parent
    archive = root / "dist/afec-classroom-materials.zip"
    if not archive.is_file():
        raise SystemExit("Build classroom materials before staging the website.")
    if output.exists() and any(output.iterdir()):
        raise SystemExit("Choose an empty output directory.")

    with zipfile.ZipFile(archive) as package:
        required = {
            f"day{day}/{name}"
            for day in range(1, 4)
            for name in ("slides.html", "exercise-student.html", "results.html")
        } | {"classroom/readiness.html"}
        if not required.issubset(package.namelist()):
            raise SystemExit("The participant archive is incomplete.")
        for day in range(1, 4):
            name = f"day{day}/slides.html"
            if package.read(name) != (root / name).read_bytes():
                raise SystemExit("Repackage current slides before staging the website.")

        output.mkdir(parents=True, exist_ok=True)
        for item in package.infolist():
            path = PurePosixPath(item.filename)
            if path.is_absolute() or ".." in path.parts:
                raise SystemExit("Unsafe archive path.")
            if item.is_dir():
                continue
            selected = (
                item.filename in required
                or path.parts[0] in {"assets", "images"}
                or item.filename == "classroom/PACKAGES.md"
                or (
                    path.parts[0] in {"day1", "day2", "day3"}
                    and len(path.parts) > 2
                    and path.parts[1] in {
                        "slides_files", "exercise-student_files", "results_files"
                    }
                )
            )
            if selected:
                target = output.joinpath(*path.parts)
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(package.read(item))

    shutil.copyfile(root / "classroom/site-index.html", output / "index.html")
    (output / ".nojekyll").touch()
    (output / "downloads").mkdir()
    shutil.copyfile(archive, output / "downloads/afec-classroom-materials.zip")
    print(f"GitHub Pages files: {output.resolve()}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, default=Path("_site"))
    build(parser.parse_args().output)
