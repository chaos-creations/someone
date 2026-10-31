"""
Changelog of the fork (the Purgatory tab of the in-game changelog).

Entries are written in commit messages, with the same :cl: syntax as upstream pull requests
(the types and tags are read from tools/pull_request_hooks/changelogConfig.js):

    :cl: optional author, the commit author by default
    add: Added a thing.
    fix: Fixed a thing.
    /:cl:

A commit that needs no entry has [no cl] in its message.

Usage:
    changelog.py check <message file>
        commit-msg hook (tools/hooks/commit-msg.hook): rejects a commit that changes game files
        without an entry or [no cl], and an entry with an unknown type.
    changelog.py collect <before> <after> <upstream ref>
        Run by .github/workflows/chaos_changelog.yml on a push to purgatory: adds the entries of the
        pushed commits, except those that came from upstream, to modular_chaos/html/changelogs/archive/.
"""

import datetime
import os
import re
import subprocess
import sys

REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
CHANGELOG_CONFIG = os.path.join(REPO_ROOT, "tools", "pull_request_hooks", "changelogConfig.js")
ARCHIVE_DIR = os.path.join(REPO_ROOT, "modular_chaos", "html", "changelogs", "archive")

SKIP_REGEX = re.compile(r"\[\s*(no|skip)\s*-?\s*cl\s*\]", re.IGNORECASE)
CHANGE_REGEX = re.compile(r"^(\w+): (.+)$")

# Changes to these need a changelog entry
GAME_PATHS = ("code/", "html/", "icons/", "interface/", "maps/", "modular_chaos/", "sound/", "strings/", "tgui/packages/")
NOT_GAME_PATHS = ("html/changelogs/", "modular_chaos/html/changelogs/", "modular_chaos/tools/")

TEMPLATE = """\
:cl:
add: Добавлен дробовик M37 в вендор морпехов.
fix: Ксеноморфы больше не застревают в дверях шаттла.
/:cl:"""


class ChangelogConfig:
    def __init__(self):
        with open(CHANGELOG_CONFIG, encoding="utf-8") as config_file:
            text = config_file.read()

        # Type alias -> the type written to the archive (the first alias of its entry)
        self.types = {}
        entries = text[text.index("CHANGELOG_ENTRIES"):]
        for aliases in re.findall(r'\[\s*\[((?:\s*"\w+"\s*,?)+)\]', entries):
            aliases = re.findall(r'"(\w+)"', aliases)
            for alias in aliases:
                self.types[alias] = aliases[0]

        self.open_tags = self._read_list(text, "CHANGELOG_OPEN_TAGS")
        self.close_tags = self._read_list(text, "CHANGELOG_CLOSE_TAGS")
        author_placeholder = re.search(r'CHANGELOG_AUTHOR_PLACEHOLDER_NAME\s*=\s*"([^"]*)"', text)
        self.author_placeholder = author_placeholder.group(1) if author_placeholder else None

        if not self.types or not self.open_tags or not self.close_tags:
            raise RuntimeError(f"Could not read the changelog types and tags from {CHANGELOG_CONFIG}")

    @staticmethod
    def _read_list(text, name):
        match = re.search(name + r"\s*=\s*\[(.*?)\]", text)
        return re.findall(r'"([^"]+)"', match.group(1)) if match else []


class Changelog:
    def __init__(self, author):
        self.author = author
        # (type, description) in the order they were written
        self.changes = []
        self.unknown_types = []


def parse_changelog(text, config):
    """Parses the first :cl: block of text the same way tools/pull_request_hooks/changelogParser.js does, or returns None."""
    lines = [line.strip() for line in text.split("\n")]
    for index, line in enumerate(lines):
        open_tag = next((tag for tag in config.open_tags if line.startswith(tag)), None)
        if open_tag is None:
            continue

        author = line[len(open_tag):].strip()
        changelog = Changelog(author if author and author != config.author_placeholder else None)
        for line in lines[index + 1:]:
            if not line:
                continue
            if any(line.startswith(tag) for tag in config.close_tags):
                break

            match = CHANGE_REGEX.match(line)
            if match:
                change_type, description = match.groups()
                if change_type in config.types:
                    changelog.changes.append((config.types[change_type], description))
                else:
                    changelog.unknown_types.append(change_type)
            elif changelog.changes:
                change_type, description = changelog.changes[-1]
                changelog.changes[-1] = (change_type, f"{description}\n{line}")
        return changelog
    return None


def git(*args):
    return subprocess.run(["git", *args], cwd=REPO_ROOT, check=True, capture_output=True, encoding="utf-8").stdout.strip()


def is_game_file(path):
    return path.startswith(GAME_PATHS) and not path.startswith(NOT_GAME_PATHS)


def check(message_file):
    # Merges, cherry-picks, reverts and rebases re-use commits that were already checked
    git_dir = git("rev-parse", "--git-dir")
    if any(os.path.exists(os.path.join(REPO_ROOT, git_dir, name)) for name in ("MERGE_HEAD", "CHERRY_PICK_HEAD", "REVERT_HEAD", "rebase-merge", "rebase-apply")):
        return 0

    with open(message_file, encoding="utf-8") as message:
        message = message.read()
    if SKIP_REGEX.search(message):
        return 0

    config = ChangelogConfig()
    changelog = parse_changelog(message, config)
    if changelog is None:
        game_files = [path for path in git("diff", "--cached", "--name-only").splitlines() if is_game_file(path)]
        if not game_files:
            return 0
        print("Коммит меняет игровые файлы, но в сообщении нет ченжлога. Добавь в сообщение блок:\n")
        print(TEMPLATE)
        print("\nили [no cl], если ченжлог не нужен (мелкая правка, рефакторинг без видимых изменений).")
        print("\nИгровые файлы в коммите:")
        for path in game_files[:10]:
            print(f"  {path}")
        if len(game_files) > 10:
            print(f"  и ещё {len(game_files) - 10}")
        return 1

    if changelog.unknown_types:
        print(f"Неизвестный тип записи в ченжлоге: {', '.join(changelog.unknown_types)}")
        print(f"Допустимые типы: {', '.join(sorted(config.types))}")
        return 1
    if not changelog.changes:
        print("Блок :cl: пустой. Добавь записи вида «add: Добавлен ...» или напиши [no cl] вместо блока.")
        return 1
    return 0


def commits_to_collect(before, after, upstream_ref):
    try:
        git("cat-file", "-e", f"{before}^{{commit}}")
    except subprocess.CalledProcessError:
        # A new branch or a force push: only the pushed commit itself
        try:
            git("merge-base", "--is-ancestor", after, upstream_ref)
            return []
        except subprocess.CalledProcessError:
            return [after]
    return git("rev-list", "--reverse", "--no-merges", after, "--not", before, upstream_ref).split()


def collect(before, after, upstream_ref):
    import yaml

    config = ChangelogConfig()
    # Month ("2026-10") -> {date: {author: [{type: description}]}}
    months = {}
    added = 0
    for commit in commits_to_collect(before, after, upstream_ref):
        message = git("log", "-1", "--format=%B", commit)
        if SKIP_REGEX.search(message):
            continue
        changelog = parse_changelog(message, config)
        if changelog is None:
            continue
        for change_type in changelog.unknown_types:
            print(f"::warning::Unknown changelog type '{change_type}' in {commit}, skipped")

        author = changelog.author or git("log", "-1", "--format=%an", commit)
        date = datetime.date.fromisoformat(git("log", "-1", "--format=%cs", commit))
        month = date.strftime("%Y-%m")
        if month not in months:
            months[month] = {}
            month_file = os.path.join(ARCHIVE_DIR, f"{month}.yml")
            if os.path.exists(month_file):
                with open(month_file, encoding="utf-8") as archive:
                    months[month] = yaml.safe_load(archive) or {}

        author_changes = months[month].setdefault(date, {}).setdefault(author, [])
        for change_type, description in changelog.changes:
            change = {change_type: description}
            if change not in author_changes:
                author_changes.append(change)
                added += 1

    os.makedirs(ARCHIVE_DIR, exist_ok=True)
    for month, entries in months.items():
        with open(os.path.join(ARCHIVE_DIR, f"{month}.yml"), "w", encoding="utf-8", newline="\n") as archive:
            yaml.dump(entries, archive, default_flow_style=False, allow_unicode=True)
    print(f"Added {added} changelog entries")
    return 0


def main(argv):
    # Russian messages must reach the VSCode commit dialog intact
    sys.stdout.reconfigure(encoding="utf-8")
    if len(argv) == 3 and argv[1] == "check":
        return check(argv[2])
    if len(argv) == 5 and argv[1] == "collect":
        return collect(argv[2], argv[3], argv[4])
    print(__doc__)
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv))
