#!/bin/bash
# custom.sh - Rename claw to cowork
# Usage: ./custom.sh [--dry-run]

set -e

DRY_RUN=""
if [ "$1" = "--dry-run" ]; then
    DRY_RUN="yes"
    echo "DRY RUN MODE - no changes will be made"
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "Project root: $PROJECT_ROOT"

# Function to perform sed replacement
replace() {
    local file="$1"
    if [ -n "$DRY_RUN" ]; then
        echo "[DRY-RUN] Would replace: $file"
        git -C "$PROJECT_ROOT" diff --stat "$file" 2>/dev/null || echo "  (no changes shown in dry-run)"
    else
        sed -i '' \
            -e 's/\.claw\./.cowork./g' \
            -e 's/\.claw\//.cowork./g' \
            -e 's/\.claw"/.cowork"/g' \
            -e 's/_claw_/.cowork./g' \
            -e 's/-claw-/.cowork./g' \
            -e 's/CLAW/COWORK/g' \
            -e 's/[Cc]law/[Cc]owork/g' \
            -e 's/claw_/cowork_/g' \
            -e 's/claw-;/cowork;/g' \
            -e 's/Claw/Cowork/g' \
            "$file"
        echo "Replaced: $file"
    fi
}

# Files to process (excluding .rs files and binary files)
declare -a FILES_TO_PROCESS=(
    "rust/USAGE.md"
    "rust/README.md"
    "rust/PARITY.md"
    "rust/MOCK_PARITY_HARNESS.md"
    "rust/CLAUDE.md"
    "rust/Cargo.toml"
    "rust/.claw.json"
    "rust/.claw/settings.json"
    "rust/scripts/install.sh"
    "USAGE.md"
    "README.md"
    "CLAUDE.md"
    ".claw.json"
)

# Process markdown files
for file in "${FILES_TO_PROCESS[@]}"; do
    if [ -f "$PROJECT_ROOT/$file" ]; then
        replace "$PROJECT_ROOT/$file"
    fi
done

# Process Rust Cargo.toml files (not .rs source files)
find "$PROJECT_ROOT/rust" -name "Cargo.toml" -type f | while read -r toml_file; do
    if [ -n "$DRY_RUN" ]; then
        echo "[DRY-RUN] Would process: $toml_file"
    else
        sed -i '' \
            -e 's/name = "claw/name = "cowork/g' \
            -e 's/\[Crates.IO\]/[project]/g' \
            -e 's/claw/cowork/g' \
            "$toml_file"
        echo "Processed: $toml_file"
    fi
done

# Process shell scripts
find "$PROJECT_ROOT" -maxdepth 3 -name "*.sh" -type f | while read -r sh_file; do
    if [[ "$sh_file" != *"/target/"* ]]; then
        if [ -n "$DRY_RUN" ]; then
            echo "[DRY-RUN] Would process: $sh_file"
        else
            sed -i '' \
                -e 's/claw/cowork/g' \
                "$sh_file"
            echo "Processed: $sh_file"
        fi
    fi
done

# Process JSON config files
find "$PROJECT_ROOT" -name "*.json" -type f | while read -r json_file; do
    if [[ "$json_file" != *"/target/"* ]] && [[ "$json_file" != *"package"* ]]; then
        if [ -n "$DRY_RUN" ]; then
            echo "[DRY-RUN] Would process: $json_file"
        else
            sed -i '' 's/claw/cowork/g' "$json_file"
            echo "Processed: $json_file"
        fi
    fi
done

# Rename directories (not in dry-run mode)
if [ -z "$DRY_RUN" ]; then
    # .claw -> .cowork
    if [ -d "$PROJECT_ROOT/.claw" ]; then
        mv "$PROJECT_ROOT/.claw" "$PROJECT_ROOT/.cowork"
        echo "Renamed: .claw -> .cowork"
    fi

    if [ -d "$PROJECT_ROOT/rust/.claw" ]; then
        mv "$PROJECT_ROOT/rust/.claw" "$PROJECT_ROOT/rust/.cowork"
        echo "Renamed: rust/.claw -> rust/.cowork"
    fi

    # Rename .claw.json files
    for f in $(find "$PROJECT_ROOT" -name ".claw.json" -type f 2>/dev/null); do
        dir=$(dirname "$f")
        mv "$f" "$dir/.cowork.json"
        echo "Renamed: $f -> $dir/.cowork.json"
    done
fi

echo ""
if [ -n "$DRY_RUN" ]; then
    echo "Dry run complete. Run without --dry-run to apply changes."
else
    echo "Customization complete!"
    echo ""
    echo "Note: Rust source files (.rs) were NOT modified."
    echo "To fully rename the CLI in Rust, you need to manually update:"
    echo "  - rust/crates/rusty-claude-cli/src/main.rs"
    echo "  - rust/crates/claw-*/ (directory names)"
    echo "  - All .rs files containing 'claw' strings"
fi
