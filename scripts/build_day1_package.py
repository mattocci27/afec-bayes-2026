"""Package Day 1 alone for reading and R practice outside the source project."""

import argparse
from html.parser import HTMLParser
import json
from pathlib import Path, PurePosixPath
import re
import shutil
import tarfile
import tempfile
from urllib.parse import unquote, urlsplit
from urllib.request import urlopen
import zipfile


KATEX_VERSION = "0.16.11"
KATEX_URL = f"https://registry.npmjs.org/katex/-/katex-{KATEX_VERSION}.tgz"


class ResourceLinks(HTMLParser):
    def __init__(self):
        super().__init__()
        self.urls = []
        self.resources = []

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        for key in ("src", "data-src", "data-background-image", "poster"):
            if key in attrs:
                self.urls.append(attrs[key])
                self.resources.append(attrs[key])
        if tag in ("a", "link") and "href" in attrs:
            self.urls.append(attrs["href"])
            if tag == "link":
                self.resources.append(attrs["href"])


def check_links(root):
    for path in root.rglob("*"):
        if path.suffix == ".html":
            parser = ResourceLinks()
            parser.feed(path.read_text())
            urls = parser.urls
            resources = parser.resources
        elif path.suffix == ".css":
            urls = re.findall(r"url\(['\"]?([^)'\"]+)", path.read_text())
            resources = urls
        else:
            continue
        if any(url.startswith(("http:", "https:", "//")) for url in resources):
            raise SystemExit(f"Remote display resource in offline package: {path}")
        for url in urls:
            parsed = urlsplit(url)
            if parsed.scheme or parsed.netloc or not parsed.path:
                continue
            target = (path.parent / unquote(parsed.path)).resolve()
            if not target.is_relative_to(root.resolve()) or not target.exists():
                raise SystemExit(f"Missing packaged resource: {path}: {url}")


def build(archive):
    project = Path(__file__).resolve().parent.parent
    for name in ("slides", "exercise-student", "results"):
        html = project / "day1" / f"{name}.html"
        source = project / "day1" / f"{name}.qmd"
        if not html.is_file() or html.stat().st_mtime < source.stat().st_mtime:
            raise SystemExit("Render current Day 1 materials first: make day1")
    student = (project / "day1/exercise-student.qmd").read_text()
    if "solutions: false" not in student or 'when-meta="solutions"' in student:
        raise SystemExit("Regenerate the solution-free participant source first.")

    cache = project / "dist/.cache" / f"katex-{KATEX_VERSION}.tgz"
    if not cache.exists():
        cache.parent.mkdir(parents=True, exist_ok=True)
        with urlopen(KATEX_URL, timeout=30) as response:
            cache.write_bytes(response.read())

    with tempfile.TemporaryDirectory(prefix="afec-day1-package-") as temp:
        root = Path(temp) / "AFEC-Day1"
        (root / "day1").mkdir(parents=True)
        (root / "assets").mkdir()
        shutil.copyfile(project / "assets/course.css", root / "assets/course.css")
        shutil.copytree(
            project / "assets/fontawesome-free-6.1.1-web",
            root / "assets/fontawesome-free-6.1.1-web",
        )
        shutil.copytree(project / "images", root / "images")
        shutil.copytree(project / "day1/slides_files", root / "day1/slides_files")
        for name in ("slides.html", "exercise-student.html", "results.html",
                     "exercise-student.qmd"):
            shutil.copyfile(project / "day1" / name, root / "day1" / name)

        # Only the distribution copy changes; source decks and the website stay intact.
        vendor = root / "assets/katex"
        vendor.mkdir(exist_ok=True)
        with tarfile.open(cache) as package:
            metadata = json.load(package.extractfile("package/package.json"))
            if metadata["version"] != KATEX_VERSION:
                raise SystemExit("Unexpected KaTeX version.")
            for item in package.getmembers():
                path = PurePosixPath(item.name)
                if not item.isfile() or path.parts[:2] != ("package", "dist"):
                    continue
                relative = path.relative_to("package/dist")
                if ".." in relative.parts:
                    raise SystemExit("Unsafe KaTeX archive path.")
                target = vendor.joinpath(*relative.parts)
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(package.extractfile(item).read())
            (vendor / "LICENSE").write_bytes(package.extractfile("package/LICENSE").read())
        for html in (root / "day1").glob("*.html"):
            content = re.sub(
                r"https://cdn\.jsdelivr\.net/npm/katex@[^/\s\"']+/dist/",
                "../assets/katex/", html.read_text()
            )
            html.write_text(content)

        # Day 1's three chunks need only tidyverse, not here(), fits or course helpers.
        chunks = re.findall(r"```\{r[^\n]*\}\n(.*?)\n```", student, flags=re.S)
        code = [chunk for chunk in chunks if "knitr::opts_chunk" not in chunk]
        (root / "day1/exercise.R").write_text(
            "# Day 1: run this code in RStudio, then change y and N.\n"
            "# Compare two surveys with survival proportion 0.4.\n"
            "# Keep the prior and grid unchanged; predict the widths first.\n\n"
            + "\n\n".join(code) + "\n"
        )
        (root / "AFEC-Day1.Rproj").write_text(
            "Version: 1.0\nRestoreWorkspace: No\nSaveWorkspace: No\n"
            "AlwaysSaveHistory: No\nEncoding: UTF-8\n"
        )
        (root / "START-HERE.html").write_text("""<!doctype html>
<html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width">
<title>AFEC-X 2026 — Day 1</title>
<style>body{font:18px/1.6 system-ui,sans-serif;max-width:760px;margin:3em auto;padding:0 1em}
a{color:#69417b}li{margin:.8em 0}code{background:#eee;padding:.1em .25em}</style>
<h1>AFEC-X 2026 — Day 1</h1>
<p>Masatoshi Katabuchi · 21 October 2026</p>
<ol>
<li><a href="day1/slides.html">Lecture slides</a></li>
<li><a href="day1/exercise-student.html">Exercise: instructions and code</a></li>
<li><a href="day1/results.html">Prepared results</a> — predict before reading the results.</li>
</ol>
<h2>Open the materials</h2>
<p>Extract the entire ZIP first, then open this file in Chrome, Edge, Firefox or Safari.
The folder can be anywhere on your computer. Keep its files and subfolders together;
do not move <code>slides.html</code> out of <code>day1/</code>.</p>
<p>Reading the HTML needs no R, RStudio, Quarto or internet connection.</p>
<h2>Run the exercise (optional)</h2>
<p>In RStudio, open <code>AFEC-Day1.Rproj</code>, then
<a href="day1/exercise.R"><code>day1/exercise.R</code></a>.
Run the supplied code, then compare a small and a larger survey with survival
proportion 0.4. Keep both plots and explain their widths.</p>
<p>The R code requires the <code>tidyverse</code> package. It does not read external
data or fitted models and works without setting a particular working directory.
CmdStan, a compiler and Docker are not needed. The supplied
<a href="day1/exercise-student.qmd">Quarto source</a> is another way to run the same code;
Quarto is only needed if you choose to render that source.</p>
<p>This package contains Day 1 only. Later sessions will be distributed separately.</p>
</html>
""")
        check_links(root)
        archive.parent.mkdir(parents=True, exist_ok=True)
        with zipfile.ZipFile(archive, "w", zipfile.ZIP_DEFLATED) as package:
            for path in sorted(root.rglob("*")):
                if path.is_file():
                    package.write(path, path.relative_to(root.parent))
    print(f"Day 1 participant ZIP: {archive} ({archive.stat().st_size / 1e6:.1f} MB)")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    build(args.output or Path(__file__).resolve().parent.parent / "dist/afec-day1-materials.zip")
