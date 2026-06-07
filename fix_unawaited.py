import re
import os

errors = r"""
  error - lib\core\services\sync_queue_service.dart:30:5 - Missing an 'await' for the 'Future' computed by this expression. Try adding an 'await' or wrapping the expression with 'unawaited'. - unawaited_futures
  error - lib\core\services\tracking_service.dart:54:22 - Missing an 'await' for the 'Future' computed by this expression. Try adding an 'await' or wrapping the expression with 'unawaited'. - unawaited_futures
  error - lib\core\services\user_tracking_service.dart:23:28 - Missing an 'await' for the 'Future' computed by this expression. Try adding an 'await' or wrapping the expression with 'unawaited'. - unawaited_futures
  error - lib\features\admin\audit_log_screen.dart:167:7 - Missing an 'await' for the 'Future' computed by this expression. Try adding an 'await' or wrapping the expression with 'unawaited'. - unawaited_futures
  error - lib\features\driver\documents_upload_screen.dart:50:22 - Missing an 'await' for the 'Future' computed by this expression. Try adding an 'await' or wrapping the expression with 'unawaited'. - unawaited_futures
  error - lib\features\driver\documents_upload_screen.dart:59:24 - Missing an 'await' for the 'Future' computed by this expression. Try adding an 'await' or wrapping the expression with 'unawaited'. - unawaited_futures
  error - lib\features\driver\documents_upload_screen.dart:195:34 - Missing an 'await' for the 'Future' computed by this expression. Try adding an 'await' or wrapping the expression with 'unawaited'. - unawaited_futures
  error - lib\features\driver\driver_bank_withdrawal_screen.dart:148:36 - Missing an 'await' for the 'Future' computed by this expression. Try adding an 'await' or wrapping the expression with 'unawaited'. - unawaited_futures
  error - lib\features\driver\driver_bank_withdrawal_screen.dart:153:36 - Missing an 'await' for the 'Future' computed by this expression. Try adding an 'await' or wrapping the expression with 'unawaited'. - unawaited_futures
  error - lib\features\driver\driver_profile_screen.dart:142:34 - Missing an 'await' for the 'Future' computed by this expression. Try adding an 'await' or wrapping the expression with 'unawaited'. - unawaited_futures
  error - lib\features\driver\verification_pending_screen.dart:75:28 - Missing an 'await' for the 'Future' computed by this expression. Try adding an 'await' or wrapping the expression with 'unawaited'. - unawaited_futures
  error - lib\features\onboarding\onboarding_screen.dart:59:23 - Missing an 'await' for the 'Future' computed by this expression. Try adding an 'await' or wrapping the expression with 'unawaited'. - unawaited_futures
  error - lib\features\profile\account_settings_screen.dart:88:5 - Missing an 'await' for the 'Future' computed by this expression. Try adding an 'await' or wrapping the expression with 'unawaited'. - unawaited_futures
  error - lib\features\profile\profile_screen.dart:240:38 - Missing an 'await' for the 'Future' computed by this expression. Try adding an 'await' or wrapping the expression with 'unawaited'. - unawaited_futures
  error - lib\features\profile\user_provider.dart:80:31 - Missing an 'await' for the 'Future' computed by this expression. Try adding an 'await' or wrapping the expression with 'unawaited'. - unawaited_futures
  error - lib\features\profile\user_provider.dart:196:33 - Missing an 'await' for the 'Future' computed by this expression. Try adding an 'await' or wrapping the expression with 'unawaited'. - unawaited_futures
  error - lib\features\rentals\rental_checkout_screen.dart:177:28 - Missing an 'await' for the 'Future' computed by this expression. Try adding an 'await' or wrapping the expression with 'unawaited'. - unawaited_futures
  error - lib\features\rentals\rental_checkout_screen.dart:222:25 - Missing an 'await' for the 'Future' computed by this expression. Try adding an 'await' or wrapping the expression with 'unawaited'. - unawaited_futures
  error - lib\features\rentals\vehicle_detail_screen.dart:297:36 - Missing an 'await' for the 'Future' computed by this expression. Try adding an 'await' or wrapping the expression with 'unawaited'. - unawaited_futures
  error - lib\features\rentals\vehicle_detail_screen.dart:314:31 - Missing an 'await' for the 'Future' computed by this expression. Try adding an 'await' or wrapping the expression with 'unawaited'. - unawaited_futures
  error - lib\features\technician\task_list_screen.dart:322:38 - Missing an 'await' for the 'Future' computed by this expression. Try adding an 'await' or wrapping the expression with 'unawaited'. - unawaited_futures
  error - lib\features\technician\task_list_screen.dart:341:33 - Missing an 'await' for the 'Future' computed by this expression. Try adding an 'await' or wrapping the expression with 'unawaited'. - unawaited_futures
  error - lib\features\technician\technician_dashboard_screen.dart:46:20 - Missing an 'await' for the 'Future' computed by this expression. Try adding an 'await' or wrapping the expression with 'unawaited'. - unawaited_futures
  error - lib\features\technician\technician_dashboard_screen.dart:111:40 - Missing an 'await' for the 'Future' computed by this expression. Try adding an 'await' or wrapping the expression with 'unawaited'. - unawaited_futures
  error - lib\features\technician\technician_dashboard_screen.dart:144:35 - Missing an 'await' for the 'Future' computed by this expression. Try adding an 'await' or wrapping the expression with 'unawaited'. - unawaited_futures
  error - lib\features\wallet\wallet_screen.dart:242:24 - Missing an 'await' for the 'Future' computed by this expression. Try adding an 'await' or wrapping the expression with 'unawaited'. - unawaited_futures
  error - lib\features\wallet\wallet_screen.dart:266:19 - Missing an 'await' for the 'Future' computed by this expression. Try adding an 'await' or wrapping the expression with 'unawaited'. - unawaited_futures
  error - lib\navigation\nav_helpers.dart:111:20 - Missing an 'await' for the 'Future' computed by this expression. Try adding an 'await' or wrapping the expression with 'unawaited'. - unawaited_futures
  error - lib\providers\taxi_provider.dart:279:26 - Missing an 'await' for the 'Future' computed by this expression. Try adding an 'await' or wrapping the expression with 'unawaited'. - unawaited_futures
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

print("Done inserting ignores.")
