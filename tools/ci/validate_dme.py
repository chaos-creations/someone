import fnmatch
import functools
import glob
import sys

reading = False

FORBID_INCLUDE = [
    # Included by _unit_test.dm
    r'code/modules/unit_tests/[!_]*.dm',

    # Included by tgs/includes.dm
    r'code/modules/tgs/**/*.dm',

    # Included by _ndatabase/includes.dm
    r'code/datums/_ndatabase/**/*.dm',

    # Included by BSQL/includes.dm
    r'code/__HELPERS/BSQL/**/*.dm',

    # Included as part of OD lints
    r'code/__pragmas.dm'
]

lines = []
total = 0
for line in sys.stdin:
    total+=1
    line = line.strip()

    if line == "// BEGIN_INCLUDE":
        reading = True
        continue
    elif line == "// END_INCLUDE":
        break
    elif not reading:
        continue

    lines.append(line)

offset = total - len(lines)
print(f"{offset} lines were ignored in output")
fail_no_include = False

for code_file in glob.glob("code/**/*.dm", recursive=True):
    dm_path = code_file.replace('/', '\\')

    included = f"#include \"{dm_path}\"" in lines
    forbid_include = False

    for forbid in FORBID_INCLUDE:
        if not fnmatch.fnmatch(code_file, forbid):
            continue

        forbid_include = True

        if included:
            print(f"{dm_path} should not be included")
            print(f"::error file={code_file},line=1,title=DME Validator::File should not be included")
            fail_no_include = True

    if forbid_include:
        continue

    if not included:
        print(f"{dm_path} is not included")
        print(f"::error file={code_file},line=1,title=DME Validator::File is not included")
        fail_no_include = True

if fail_no_include:
    sys.exit(1)

def compare_lines(a, b):
    # Remove initial include as well as the final quotation mark
    a = a[len("#include \""):-1].lower()
    b = b[len("#include \""):-1].lower()

    a_segments = a.split('\\')
    b_segments = b.split('\\')

    for (a_segment, b_segment) in zip(a_segments, b_segments):
        a_is_file = a_segment.endswith(".dm")
        b_is_file = b_segment.endswith(".dm")

        # code\something.dm will ALWAYS come before code\directory\something.dm
        if a_is_file and not b_is_file:
            return -1

        if b_is_file and not a_is_file:
            return 1

        # interface\something.dm will ALWAYS come after code\something.dm
        if a_segment != b_segment:
            return (a_segment > b_segment) - (a_segment < b_segment)

    raise ValueError(f"Two lines were exactly the same ({a} vs. {b})")

sorted_lines = sorted(lines, key = functools.cmp_to_key(compare_lines))
for (index, line) in enumerate(lines):
    if sorted_lines[index] != line:
        print(f"The include at line {index + offset} is out of order ({line}, expected {sorted_lines[index]})")
        print(f"::error file=tgstation.dme,line={index+offset},title=DME Validator::The include at line {index + offset} is out of order ({line}, expected {sorted_lines[index]})")
        sys.exit(1)

# CHAOS-EDIT START: also validate modular_chaos/includes.dm, which lists the fork's own files relative to modular_chaos/
MODULAR_DIR = "modular_chaos"
MODULAR_INCLUDES = f"{MODULAR_DIR}/includes.dm"

MODULAR_FORBID_INCLUDE = [
    # Included by modular_chaos/code/modules/unit_tests/_unit_tests.dm
    r'code/modules/unit_tests/[!_]*.dm',
]

modular_include_path = MODULAR_INCLUDES.replace('/', '\\')
if f"#include \"{modular_include_path}\"" not in lines:
    print(f"{MODULAR_INCLUDES} is not included")
    print(f"::error file=colonialmarines.dme,line=1,title=DME Validator::{MODULAR_INCLUDES} is not included")
    sys.exit(1)

modular_lines = []
modular_line_numbers = []
with open(MODULAR_INCLUDES) as modular_includes:
    for line_number, line in enumerate(modular_includes, start = 1):
        line = line.strip()
        if not line.startswith("#include"):
            continue
        modular_lines.append(line)
        modular_line_numbers.append(line_number)

fail_no_include = False

for modular_file in glob.glob(f"{MODULAR_DIR}/**/*.dm", recursive=True):
    modular_file = modular_file.replace('\\', '/')
    if modular_file == MODULAR_INCLUDES:
        continue

    relative_path = modular_file[len(MODULAR_DIR) + 1:]
    dm_path = relative_path.replace('/', '\\')

    included = f"#include \"{dm_path}\"" in modular_lines
    forbid_include = False

    for forbid in MODULAR_FORBID_INCLUDE:
        if not fnmatch.fnmatch(relative_path, forbid):
            continue

        forbid_include = True

        if included:
            print(f"{modular_file} should not be included in {MODULAR_INCLUDES}")
            print(f"::error file={modular_file},line=1,title=DME Validator::File should not be included in {MODULAR_INCLUDES}")
            fail_no_include = True

    if forbid_include:
        continue

    if not included:
        print(f"{modular_file} is not included in {MODULAR_INCLUDES}")
        print(f"::error file={modular_file},line=1,title=DME Validator::File is not included in {MODULAR_INCLUDES}")
        fail_no_include = True

if fail_no_include:
    sys.exit(1)

sorted_modular_lines = sorted(modular_lines, key = functools.cmp_to_key(compare_lines))
for (index, line) in enumerate(modular_lines):
    if sorted_modular_lines[index] != line:
        line_number = modular_line_numbers[index]
        print(f"The include at line {line_number} of {MODULAR_INCLUDES} is out of order ({line}, expected {sorted_modular_lines[index]})")
        print(f"::error file={MODULAR_INCLUDES},line={line_number},title=DME Validator::The include at line {line_number} is out of order ({line}, expected {sorted_modular_lines[index]})")
        sys.exit(1)
# CHAOS-EDIT END
