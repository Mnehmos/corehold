# Corehold
# File: tools/check_file_headers.py
# Purpose: Validate that human-authored files contain workflow headers
#
# Contribution Flow:
# Issue → Branch → Test → Implement → PR → Review → Revise → Docs → Squash Merge → Main
#
# Rules:
# - Do not edit without a linked issue.
# - Keep changes scoped to the issue.
# - Add or update tests when practical.
# - Update docs when behavior, architecture, setup, or data formats change.

"""
File header validation script.

Walks the repository and checks that human-authored files
contain the Contribution Flow workflow marker.

Usage:
    python tools/check_file_headers.py

Exits 0 if all required files have headers.
Exits 1 with a list of files missing headers.
"""

import os
import sys

# File extensions that require workflow headers
HEADER_EXTENSIONS = {
    ".gd", ".cs", ".py", ".ts", ".tsx", ".js", ".jsx",
    ".sh", ".yml", ".yaml", ".toml", ".ini", ".cfg",
}

# Markdown uses HTML comment headers
MD_EXTENSIONS = {".md"}

# Directories to skip entirely
SKIP_DIRS = {
    ".git", ".godot", ".import", "build", "dist", "exports",
    "assets", "node_modules", ".kilo", ".kilocode", ".opencode",
    "__pycache__",
}

# File extensions to skip (cannot safely contain comments)
SKIP_EXTENSIONS = {
    ".json", ".tscn", ".tres", ".import", ".png", ".jpg",
    ".jpeg", ".webp", ".svg", ".ogg", ".wav", ".mp3",
    ".ttf", ".otf", ".gdextension", ".uid", ".gitkeep",
    ".lock", ".package-lock.json",
}

# Files to skip by name
SKIP_FILES = {
    "project.godot",
}

WORKFLOW_MARKER = "Contribution Flow:"

# Allowlist of files that are exempt from header enforcement
EXEMPT_FILES = set()


def should_check(filepath: str) -> bool:
    """Determine if a file should be checked for headers."""
    basename = os.path.basename(filepath)
    _, ext = os.path.splitext(filepath)

    if basename in SKIP_FILES:
        return False
    if ext in SKIP_EXTENSIONS:
        return False
    if ext in HEADER_EXTENSIONS:
        return True
    if ext in MD_EXTENSIONS:
        return True
    return False


def has_header(filepath: str) -> bool:
    """Check if a file contains the workflow marker."""
    try:
        with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
            content = f.read(4096)  # Only read first 4KB
            return WORKFLOW_MARKER in content
    except (OSError, PermissionError):
        return False


def find_repo_root() -> str:
    """Find the repository root by walking up from this script."""
    current = os.path.dirname(os.path.abspath(__file__))
    for _ in range(10):
        if os.path.exists(os.path.join(current, "project.godot")):
            return current
        parent = os.path.dirname(current)
        if parent == current:
            break
        current = parent
    return os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def main():
    repo_root = find_repo_root()
    missing = []
    checked = 0

    for root, dirs, files in os.walk(repo_root):
        # Skip excluded directories
        dirs[:] = [d for d in dirs if d not in SKIP_DIRS]

        for filename in files:
            filepath = os.path.join(root, filename)
            relpath = os.path.relpath(filepath, repo_root)

            if relpath.replace("\\", "/") in EXEMPT_FILES:
                continue

            if should_check(filepath):
                checked += 1
                if not has_header(filepath):
                    missing.append(relpath)

    print(f"Checked {checked} files for workflow headers.")

    if missing:
        print(f"\nMissing workflow headers ({len(missing)}):")
        for path in sorted(missing):
            print(f"  - {path}")
        sys.exit(1)
    else:
        print("OK: all required files contain workflow headers.")
        sys.exit(0)


if __name__ == "__main__":
    main()
