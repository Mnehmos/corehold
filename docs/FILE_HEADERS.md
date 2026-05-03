<!--
Corehold
File: docs/FILE_HEADERS.md
Purpose: File header standard and exemption rules

Contribution Flow:
Issue → Branch → Test → Implement → PR → Review → Revise → Docs → Squash Merge → Main

Rules:
- Do not edit without a linked issue.
- Keep changes scoped to the issue.
- Update related docs when behavior, architecture, setup, or data formats change.
-->

# File Header Standard

Every human-authored source or documentation file should include a lightweight project header.

The header exists to remind human and LLM contributors that all changes must follow the project workflow.

## Workflow

```
Issue → Branch → Test → Implement → PR → Review → Revise → Docs → Squash Merge → Main
```

## Files That Require Headers

Headers are required for human-authored files that support comments, including:

- `.gd`
- `.cs`
- `.py`
- `.ts`
- `.tsx`
- `.js`
- `.jsx`
- `.sh`
- `.md`
- `.yml`
- `.yaml`
- `.toml`
- `.ini`
- `.cfg`

## Files That Should Not Be Modified For Headers

Do not add headers to:

- `.json` — JSON does not support comments
- `.tscn` — Godot scene files are editor-managed
- `.tres` — Godot resource files are editor-managed
- `.import` — Godot import files are generated
- `.png`, `.jpg`, `.jpeg`, `.webp` — Binary images
- `.svg` — Unless manually authored and safe
- `.ogg`, `.wav`, `.mp3` — Binary audio
- `.ttf`, `.otf` — Binary fonts
- `.gdextension` — Generated extension config
- `.uid` — Godot generated
- `project.godot` — Engine-managed config (INI format, not safe for arbitrary comments)
- Any file in `.godot/` — Generated cache
- Any file in `assets/` — Binary assets
- Build artifacts, vendor files

For data files that cannot safely contain comments, document ownership and workflow in the nearest README or data documentation file.

## Standard GDScript Header

```gdscript
# Corehold
# File: <relative/path>
# Purpose: <one-sentence purpose>
#
# Contribution Flow:
# Issue → Branch → Test → Implement → PR → Review → Revise → Docs → Squash Merge → Main
#
# Rules:
# - Do not edit without a linked issue.
# - Keep changes scoped to the issue.
# - Add or update tests when practical.
# - Update docs when behavior, architecture, setup, or data formats change.
```

## Standard Python Header

```python
# Corehold
# File: <relative/path>
# Purpose: <one-sentence purpose>
#
# Contribution Flow:
# Issue → Branch → Test → Implement → PR → Review → Revise → Docs → Squash Merge → Main
#
# Rules:
# - Do not edit without a linked issue.
# - Keep changes scoped to the issue.
# - Add or update tests when practical.
# - Update docs when behavior, architecture, setup, or data formats change.
```

## Standard Markdown Header

Use an HTML comment at the top:

```md
<!--
Corehold
File: <relative/path>
Purpose: <one-sentence purpose>

Contribution Flow:
Issue → Branch → Test → Implement → PR → Review → Revise → Docs → Squash Merge → Main

Rules:
- Do not edit without a linked issue.
- Keep changes scoped to the issue.
- Update related docs when behavior, architecture, setup, or data formats change.
-->
```

## Standard YAML Header

```yaml
# Corehold
# File: <relative/path>
# Purpose: <one-sentence purpose>
#
# Contribution Flow:
# Issue → Branch → Test → Implement → PR → Review → Revise → Docs → Squash Merge → Main
#
# Rules:
# - Do not edit without a linked issue.
# - Keep changes scoped to the issue.
# - Update docs when behavior, architecture, setup, or data formats change.
```

## Header Validation

Run the validation script to check for missing headers:

```
python tools/check_file_headers.py
```

Expected output on success:

```
OK: all required files contain workflow headers.
```

Or on failure:

```
Missing workflow headers:
- scripts/core/GameState.gd
- docs/ARCHITECTURE.md
```
