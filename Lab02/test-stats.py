#!/usr/bin/env python3
import math
import subprocess
import sys

program = sys.argv[1]
cases = [([18, 20, 22, 24], [4, 21, 18, 24, 5]),
         ([7, 7, 7], [3, 7, 7, 7, 0]),
         ([-5, -1], [2, -3, -5, -1, 4]),
         ([2.5], [1, 2.5, 2.5, 2.5, 0]),
         ([1e9 + 1, 1e9 + 2, 1e9 + 3], [3, 1e9 + 2, 1e9 + 1, 1e9 + 3, 2/3])]
for values, expected in cases:
    result = subprocess.run([program, *map(str, values)], capture_output=True, text=True, check=True)
    actual = [float(item.split('=')[1]) for item in result.stdout.split()]
    assert len(actual) == len(expected)
    assert all(math.isclose(a, b, rel_tol=2e-8, abs_tol=1e-8) for a, b in zip(actual, expected)), (actual, expected)
    print(result.stdout.strip())
for args in [[], ['nan'], ['inf'], ['12x'], [''], ['1e999'], ['-1e308', '1e308']]:
    result = subprocess.run([program, *args], capture_output=True, text=True)
    assert result.returncode == 2, (args, result)
    print('rejected:', repr(args))
print('PASS: 5 numerical cases and 7 invalid/overflow cases')
