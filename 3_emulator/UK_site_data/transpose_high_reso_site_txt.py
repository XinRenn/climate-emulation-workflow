from __future__ import annotations

import argparse
import re
import shutil
from pathlib import Path

import numpy as np


ROOT_DIR = Path(__file__).resolve().parents[1]
DEFAULT_INPUT_ROOT = ROOT_DIR / "prediction" / "results_on_sites" / "high_reso_sites"

FILENAME_PATTERN = re.compile(
    r"^(?P<var>pr|tas)_(?P<scenario>[^_]+)_UK_site(?P<site>\d+)\.txt$"
)

VARIABLE_METADATA = {
    "pr": {
        "heading_name": "precip",
        "units": "mm month^-1",
        "long_name": "Surface Precipitation",
    },
    "tas": {
        "heading_name": "tas",
        "units": "degC",
        "long_name": "2m Air Temperature",
    },
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Transpose all high-resolution UK site txt files so that each row is an "
            "ensemble member and each column is a time step, then write low-resolution-style headings."
        )
    )
    parser.add_argument(
        "--input-root",
        type=Path,
        default=DEFAULT_INPUT_ROOT,
        help="Root directory containing site_1 ... site_112 folders.",
    )
    parser.add_argument(
        "--site-start",
        type=int,
        default=1,
        help="First site number to process.",
    )
    parser.add_argument(
        "--site-end",
        type=int,
        default=112,
        help="Last site number to process.",
    )
    parser.add_argument(
        "--site-index-offset",
        type=int,
        default=0,
        help="Offset applied when writing the site index in the heading. Default keeps site_1 as index 1.",
    )
    parser.add_argument(
        "--no-backup",
        action="store_true",
        help="Do not create .bak copies before overwriting files.",
    )
    parser.add_argument(
        "--overwrite-converted",
        action="store_true",
        help="Reprocess files even if they already contain the target heading.",
    )
    return parser.parse_args()


def has_target_heading(file_path: Path) -> bool:
    with file_path.open("r", encoding="utf-8") as handle:
        for _ in range(8):
            line = handle.readline()
            if not line:
                break
            if "Each row is an ensemble member, each column is a time step" in line:
                return True
    return False


def extract_metadata(file_path: Path, site_index_offset: int) -> dict[str, str]:
    match = FILENAME_PATTERN.match(file_path.name)
    if not match:
        raise ValueError(f"Unrecognized file name format: {file_path.name}")

    var_key = match.group("var")
    scenario = match.group("scenario")
    site_number = int(match.group("site"))
    variable_meta = VARIABLE_METADATA[var_key]

    return {
        "variable": variable_meta["heading_name"],
        "scenario": scenario,
        "site_index": str(site_number + site_index_offset),
        "units": variable_meta["units"],
        "long_name": variable_meta["long_name"],
    }


def read_numeric_matrix(file_path: Path) -> np.ndarray:
    data = np.loadtxt(file_path, comments="#")
    data = np.atleast_2d(data)
    return data


def build_heading(metadata: dict[str, str]) -> str:
    lines = [
        f"# # Variable: {metadata['variable']}",
        f"# # Scenario: {metadata['scenario']}",
        f"# # Site index: {metadata['site_index']}",
        f"# # Units: {metadata['units']}",
        f"# # Long name: {metadata['long_name']}",
        "# # Each row is an ensemble member, each column is a time step (AP kyr).",
        "# # Values are anomalies unless otherwise stated.",
        "# #",
    ]
    return "\n".join(lines) + "\n"


def write_transposed_file(
    file_path: Path,
    transposed_data: np.ndarray,
    heading: str,
    create_backup: bool,
) -> None:
    if create_backup:
        backup_path = file_path.with_suffix(file_path.suffix + ".bak")
        shutil.copy2(file_path, backup_path)

    with file_path.open("w", encoding="utf-8") as handle:
        handle.write(heading)
        np.savetxt(handle, transposed_data, fmt="%.6f")


def process_file(
    file_path: Path,
    site_index_offset: int,
    create_backup: bool,
    overwrite_converted: bool,
) -> str:
    if not overwrite_converted and has_target_heading(file_path):
        return f"SKIP already converted: {file_path}"

    metadata = extract_metadata(file_path, site_index_offset)
    original_data = read_numeric_matrix(file_path)
    transposed_data = original_data.T
    heading = build_heading(metadata)
    write_transposed_file(file_path, transposed_data, heading, create_backup)

    return (
        f"OK {file_path.name}: {original_data.shape[0]} time steps x {original_data.shape[1]} ensemble members "
        f"-> {transposed_data.shape[0]} ensemble members x {transposed_data.shape[1]} time steps"
    )


def iter_target_files(input_root: Path, site_start: int, site_end: int) -> list[Path]:
    files: list[Path] = []
    for site_number in range(site_start, site_end + 1):
        site_dir = input_root / f"site_{site_number}"
        if not site_dir.is_dir():
            continue
        files.extend(sorted(site_dir.glob("*.txt")))
    return files


def main() -> None:
    args = parse_args()

    input_root = args.input_root.resolve()
    create_backup = not args.no_backup
    target_files = iter_target_files(input_root, args.site_start, args.site_end)

    if not target_files:
        raise SystemExit(f"No txt files found under {input_root}")

    print(f"Input root: {input_root}")
    print(f"Files found: {len(target_files)}")
    print(f"Backup enabled: {create_backup}")
    print()

    processed = 0
    skipped = 0
    failed = 0

    for file_path in target_files:
        try:
            message = process_file(
                file_path=file_path,
                site_index_offset=args.site_index_offset,
                create_backup=create_backup,
                overwrite_converted=args.overwrite_converted,
            )
            print(message)
            if message.startswith("SKIP"):
                skipped += 1
            else:
                processed += 1
        except Exception as exc:
            print(f"FAIL {file_path}: {exc}")
            failed += 1

    print()
    print(f"Processed: {processed}")
    print(f"Skipped: {skipped}")
    print(f"Failed: {failed}")

    if failed:
        raise SystemExit(1)


if __name__ == "__main__":
    main()