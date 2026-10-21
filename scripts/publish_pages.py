"""Stage or publish course materials without changing the source Git checkout."""

import argparse
from pathlib import Path
import shutil
import subprocess
import tempfile

from build_pages import build


ROOT = Path(__file__).resolve().parent.parent


def stage(root: Path = ROOT) -> Path:
    """Replace the generated site only after staging succeeds."""
    dist = root / "dist"
    dist.mkdir(exist_ok=True)
    site = dist / "site"
    if site.is_symlink() or (site.exists() and not site.is_dir()):
        raise SystemExit("dist/site must be a generated directory, not a file or symlink.")
    if (site / ".git").exists():
        raise SystemExit("dist/site contains a Git checkout; move it before staging.")
    with tempfile.TemporaryDirectory(prefix=".site-build-", dir=dist) as work:
        pending = Path(work) / "site"
        build(pending)
        previous = Path(work) / "previous"
        if site.exists():
            site.rename(previous)
        try:
            pending.rename(site)
        except OSError:
            if previous.exists():
                previous.rename(site)
            raise
    print(f"Website ready: {site}")
    return site


def git(repository: Path, *args: str) -> str:
    result = subprocess.run(
        ["git", "-C", str(repository), *args],
        check=True, capture_output=True, text=True,
    )
    return result.stdout.strip()


def publish(site: Path, repository: Path = ROOT) -> bool:
    """Append to origin/gh-pages using a disposable clone; never force push."""
    for item in ("index.html", ".nojekyll", "downloads/afec-classroom-materials.zip"):
        if not (site / item).is_file():
            raise SystemExit("Website is incomplete. Run make site first.")
    if (site / ".git").exists():
        raise SystemExit("The generated website must not contain Git metadata.")
    remote = git(repository, "remote", "get-url", "--push", "origin")
    try:
        name = git(repository, "config", "user.name")
        email = git(repository, "config", "user.email")
    except subprocess.CalledProcessError as error:
        raise SystemExit("Configure Git user.name and user.email before publishing.") from error

    with tempfile.TemporaryDirectory(prefix="afec-publish-") as work:
        checkout = Path(work) / "gh-pages"
        git(Path(work), "clone", "--single-branch", "--branch", "gh-pages",
            "--", remote, str(checkout))
        for item in checkout.iterdir():
            if item.name == ".git":
                continue
            if item.is_dir() and not item.is_symlink():
                shutil.rmtree(item)
            else:
                item.unlink()
        shutil.copytree(site, checkout, dirs_exist_ok=True)
        git(checkout, "add", "--all")
        changed = subprocess.run(
            ["git", "-C", str(checkout), "diff", "--cached", "--quiet"],
            check=False,
        )
        if changed.returncode == 0:
            print("Website is already current; no commit or push needed.")
            return False
        if changed.returncode != 1:
            raise SystemExit("Could not inspect staged website changes.")
        git(checkout, "-c", f"user.name={name}", "-c", f"user.email={email}",
            "commit", "-m", "Update course website")
        git(checkout, "push", "origin", "HEAD:refs/heads/gh-pages")
        print("Pushed origin/gh-pages. GitHub Pages will deploy the update.")
        return True


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=("stage", "publish"))
    args = parser.parse_args()
    try:
        if args.action == "stage":
            stage()
        else:
            publish(ROOT / "dist/site")
    except subprocess.CalledProcessError as error:
        raise SystemExit(error.stderr.strip() or str(error)) from error


if __name__ == "__main__":
    main()
