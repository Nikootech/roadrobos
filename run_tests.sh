#!/bin/bash
# Exit on failure
set -e

echo "=================================================="
echo "🚀 Running RoadRobos Integration Tests..."
echo "=================================================="

echo "👉 [1/4] Running Payment Verification Test..."
flutter test test/integration/payment_verification_test.dart

echo "👉 [2/4] Running Wallet Balance Test..."
flutter test test/integration/wallet_balance_test.dart

echo "👉 [3/4] Running Sync Queue Test..."
flutter test test/integration/sync_queue_test.dart

echo "👉 [4/4] Running Timestamp UTC Test..."
flutter test test/integration/timestamp_test.dart

echo "=================================================="
echo "✅ All integration tests completed successfully!"
echo "=================================================="
