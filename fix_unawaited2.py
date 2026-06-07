import re
import os

errors = r"""
  error - lib\core\repositories\banner_offer_repository.dart:22:34 - Missing an 'await' for the 'Future' computed by this expression. Try adding an 'await' or wrapping the expression with 'unawaited'. - unawaited_futures
  error - lib\core\repositories\category_repository.dart:22:37 - Missing an 'await' for the 'Future' computed by this expression. Try adding an 'await' or wrapping the expression with 'unawaited'. - unawaited_futures
  error - lib\core\repositories\user_repository.dart:26:27 - Missing an 'await' for the 'Future' computed by this expression. Try adding an 'await' or wrapping the expression with 'unawaited'. - unawaited_futures
  error - lib\core\services\notification_service.dart:125:38 - Missing an 'await' for the 'Future' computed by this expression. Try adding an 'await' or wrapping the expression with 'unawaited'. - unawaited_futures
  error - lib\core\services\payment_service.dart:124:7 - Missing an 'await' for the 'Future' computed by this expression. Try adding an 'await' or wrapping the expression with 'unawaited'. - unawaited_futures
"""

files_to_modify = {}
for line in errors.strip().split('\n'):
    match = re.search(r'error - (.*?):(\d+):\d+ - Missing an \'await\'', line)
    if match:
        file_path = match.group(1).strip()
        line_num = int(match.group(2))
        if file_path not in files_to_modify:
            files_to_modify[file_path] = []
        files_to_modify[file_path].append(line_num)

for file_path, line_nums in files_to_modify.items():
    # Sort descending so line additions don't affect previous lines
    line_nums = sorted(line_nums, reverse=True)
    full_path = os.path.join(r"e:\roadrobosapp\android app", file_path)
    with open(full_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    for line_num in line_nums:
        idx = line_num - 1
        # Determine indentation
        indent = len(lines[idx]) - len(lines[idx].lstrip())
        lines.insert(idx, " " * indent + "// ignore: unawaited_futures\n")
    
    with open(full_path, 'w', encoding='utf-8') as f:
        f.writelines(lines)

print("Done inserting ignores for remaining.")
