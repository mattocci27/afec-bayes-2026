"""Publication checks use temporary local repositories, never GitHub."""

from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))
from publish_pages import git, publish, stage


class PublicationTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)

    def test_failed_staging_keeps_previous_site(self):
        site = self.root / "dist/site"
        site.mkdir(parents=True)
        (site / "index.html").write_text("previous site")
        with patch("publish_pages.build", side_effect=SystemExit("stale archive")):
            with self.assertRaisesRegex(SystemExit, "stale archive"):
                stage(self.root)
        self.assertEqual((site / "index.html").read_text(), "previous site")

    def test_successful_staging_removes_obsolete_files(self):
        site = self.root / "dist/site"
        site.mkdir(parents=True)
        (site / "obsolete.html").write_text("old")

        def build_fixture(output):
            output.mkdir()
            (output / "index.html").write_text("new")

        with patch("publish_pages.build", side_effect=build_fixture):
            stage(self.root)
        self.assertEqual((site / "index.html").read_text(), "new")
        self.assertFalse((site / "obsolete.html").exists())

    def test_publish_preserves_history_and_source_checkout(self):
        remote = self.root / "remote.git"
        source = self.root / "source"
        source.mkdir()
        git(self.root, "init", "--bare", str(remote))
        git(source, "init", "-b", "gh-pages")
        git(source, "config", "user.name", "Local publication test")
        git(source, "config", "user.email", "test@example.invalid")
        (source / "index.html").write_text("old site")
        (source / "obsolete.html").write_text("remove on next publication")
        git(source, "add", ".")
        git(source, "commit", "-m", "Initial website")
        previous = git(source, "rev-parse", "HEAD")
        git(source, "remote", "add", "origin", str(remote))
        git(source, "push", "origin", "gh-pages")
        git(source, "switch", "-c", "main")
        git(source, "push", "origin", "main")
        (source / "index.html").write_text("uncommitted source edit")
        (source / "draft.txt").write_text("untracked source draft")
        status = git(source, "status", "--porcelain")

        site = self.root / "site"
        (site / "downloads").mkdir(parents=True)
        (site / "index.html").write_text("new site")
        (site / ".nojekyll").touch()
        (site / "downloads/afec-classroom-materials.zip").write_bytes(b"archive fixture")

        self.assertTrue(publish(site, source))
        published = git(remote, "rev-parse", "gh-pages")
        self.assertEqual(git(remote, "rev-parse", "gh-pages^"), previous)
        self.assertEqual(git(remote, "show", "gh-pages:index.html"), "new site")
        self.assertNotIn("obsolete.html", git(remote, "ls-tree", "--name-only", "gh-pages"))
        self.assertEqual(git(source, "branch", "--show-current"), "main")
        self.assertEqual(git(source, "rev-parse", "HEAD"), previous)
        self.assertEqual(git(remote, "rev-parse", "main"), previous)
        self.assertEqual(git(source, "status", "--porcelain"), status)
        self.assertFalse(publish(site, source))
        self.assertEqual(git(remote, "rev-parse", "gh-pages"), published)

    def test_incomplete_site_fails_before_git_access(self):
        with self.assertRaisesRegex(SystemExit, "incomplete"):
            publish(self.root / "missing-site", self.root / "not-a-repository")


if __name__ == "__main__":
    unittest.main()
