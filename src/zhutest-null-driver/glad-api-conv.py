#!/usr/bin/env python3
import re
import sys

# Regular expressions for the typedef and the #define line.
typedef_re = re.compile(
    r'typedef\s+(.+?)\s*\(APIENTRYP\s+\S+\)\((.*)\);'
)
define_re = re.compile(
    r'#define\s+(\S+)\s+\S+'
)

def convert_definitions(lines):
    output = []
    i = 0
    while i < len(lines):
        # Skip empty lines
        if not lines[i].strip():
            i += 1
            continue

        # Expect groups of 3 lines.
        if i + 2 >= len(lines):
            break

        line1 = lines[i].strip()
        line2 = lines[i+1].strip()  # unused here, but it confirms the grouping
        line3 = lines[i+2].strip()

        # Extract return type and parameters from the typedef line.
        m_typedef = typedef_re.match(line1)
        if not m_typedef:
            sys.stderr.write(f"Skipping unrecognized format in: {line1}\n")
            i += 3
            continue

        ret_type = m_typedef.group(1)
        params = m_typedef.group(2)

        # Extract the function name from the #define line.
        m_define = define_re.match(line3)
        if not m_define:
            i += 3
            continue

        func_name = m_define.group(1)

        # Build the function declaration.
        if ret_type == "void":
            decl = f"{ret_type} {func_name}({params}) {{}}"
        else:
            decl = f"{ret_type} {func_name}({params});"
        output.append(decl)
        i += 3
    return output

# Convert:
#   #typedef void (APIENTRYP PFNGLDRAWELEMENTSPROC)(GLenum mode, GLsizei count, GLenum type, const void *indices);
#   GLAPI PFNGLDRAWELEMENTSPROC glad_glDrawElements;
#   #define glDrawElements glad_glDrawElements
# To:
#   void glDrawElements(GLenum mode, GLsizei count, GLenum type, const void *indices) {}
def main():
    # Read all lines from the input file or standard input.
    lines = sys.stdin.readlines()
    results = convert_definitions(lines)
    for decl in results:
        print(decl)

if __name__ == '__main__':
    main()
