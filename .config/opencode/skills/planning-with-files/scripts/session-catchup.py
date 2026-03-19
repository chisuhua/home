#!/usr/bin/env python3
"""
session-catchup.py - Recover context from previous session
Checks for unsynced changes and helps reconcile planning files.
"""

import os
import sys
import subprocess
from pathlib import Path
from datetime import datetime


def run_command(cmd: list[str]) -> tuple[str, str, int]:
    """Run a shell command and return output."""
    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=30
        )
        return result.stdout, result.stderr, result.returncode
    except Exception as e:
        return "", str(e), 1


def check_git_changes(project_dir: Path) -> dict:
    """Check for uncommitted git changes."""
    os.chdir(project_dir)
    
    # Check git status
    stdout, stderr, code = run_command(["git", "status", "--porcelain"])
    
    changes = {
        "modified": [],
        "added": [],
        "deleted": [],
        "untracked": []
    }
    
    if code == 0:
        for line in stdout.strip().split("\n"):
            if not line:
                continue
            status = line[:2].strip()
            file_path = line[3:]
            
            if status == "M":
                changes["modified"].append(file_path)
            elif status == "A":
                changes["added"].append(file_path)
            elif status == "D":
                changes["deleted"].append(file_path)
            elif status == "??":
                changes["untracked"].append(file_path)
    
    return changes


def check_planning_files(project_dir: Path) -> dict:
    """Check existence and modification time of planning files."""
    planning_files = ["task_plan.md", "findings.md", "progress.md"]
    status = {}
    
    for file_name in planning_files:
        file_path = project_dir / file_name
        if file_path.exists():
            mtime = datetime.fromtimestamp(file_path.stat().st_mtime)
            status[file_name] = {
                "exists": True,
                "modified": mtime,
                "size": file_path.stat().st_size
            }
        else:
            status[file_name] = {"exists": False}
    
    return status


def generate_report(project_dir: Path) -> str:
    """Generate a catchup report."""
    report = []
    report.append("=" * 60)
    report.append("SESSION CATCHUP REPORT")
    report.append(f"Project: {project_dir}")
    report.append(f"Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    report.append("=" * 60)
    report.append("")
    
    # Check planning files
    report.append("## Planning Files Status")
    planning_status = check_planning_files(project_dir)
    
    for file_name, status in planning_status.items():
        if status["exists"]:
            report.append(f"✓ {file_name}")
            report.append(f"  Modified: {status['modified'].strftime('%Y-%m-%d %H:%M')}")
            report.append(f"  Size: {status['size']} bytes")
        else:
            report.append(f"✗ {file_name} - NOT FOUND")
    
    report.append("")
    
    # Check git changes
    report.append("## Git Changes")
    git_changes = check_git_changes(project_dir)
    
    total_changes = sum(len(v) for v in git_changes.values())
    
    if total_changes == 0:
        report.append("No uncommitted changes")
    else:
        if git_changes["modified"]:
            report.append(f"Modified ({len(git_changes['modified'])}):")
            for f in git_changes["modified"][:5]:
                report.append(f"  - {f}")
        
        if git_changes["added"]:
            report.append(f"Added ({len(git_changes['added'])}):")
            for f in git_changes["added"][:5]:
                report.append(f"  + {f}")
        
        if git_changes["untracked"]:
            report.append(f"Untracked ({len(git_changes['untracked'])}):")
            for f in git_changes["untracked"][:5]:
                report.append(f"  ? {f}")
    
    report.append("")
    report.append("=" * 60)
    report.append("RECOMMENDATIONS")
    report.append("=" * 60)
    
    # Check if planning files exist
    existing_planning = [f for f, s in planning_status.items() if s["exists"]]
    
    if not existing_planning:
        report.append("⚠ No planning files found. Create them before starting work.")
        report.append("  Run: npx skills add openclaw/skills --skill planning-with-files")
    else:
        report.append("✓ Planning files exist")
        report.append("  → Read task_plan.md to understand current phase")
        report.append("  → Review findings.md for discoveries")
        report.append("  → Check progress.md for session history")
    
    if total_changes > 0:
        report.append("⚠ Uncommitted changes detected")
        report.append("  → Run 'git diff' to review changes")
        report.append("  → Update planning files if phases completed")
    
    report.append("")
    
    return "\n".join(report)


def main():
    """Main entry point."""
    if len(sys.argv) > 1:
        project_dir = Path(sys.argv[1])
    else:
        project_dir = Path.cwd()
    
    if not project_dir.exists():
        print(f"Error: Directory not found: {project_dir}")
        sys.exit(1)
    
    report = generate_report(project_dir)
    print(report)


if __name__ == "__main__":
    main()
