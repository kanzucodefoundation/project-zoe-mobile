#!/bin/bash

# Test script to check if the report endpoints are working
echo "Testing Report Endpoints..."

# Get the base URL from your API configuration
BASE_URL="https://staging-projectzoe.kanzucodefoundation.org/server/api"

echo "1. Testing /reports/submissions endpoint..."
curl -X GET "$BASE_URL/reports/submissions" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  --connect-timeout 10 \
  --max-time 30 \
  -w "HTTP Status: %{http_code}\n" \
  -s || echo "❌ Failed to connect to /reports/submissions"

echo ""
echo "2. Testing /report-data endpoint..."
curl -X GET "$BASE_URL/report-data" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  --connect-timeout 10 \
  --max-time 30 \
  -w "HTTP Status: %{http_code}\n" \
  -s || echo "❌ Failed to connect to /report-data"

echo ""
echo "3. Testing /reports endpoint..."
curl -X GET "$BASE_URL/reports" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  --connect-timeout 10 \
  --max-time 30 \
  -w "HTTP Status: %{http_code}\n" \
  -s || echo "❌ Failed to connect to /reports"

echo ""
echo "Test completed. Check the HTTP status codes above:"
echo "- 200: Success"
echo "- 404: Endpoint not found"
echo "- 500: Server error"
echo "- Connection failed: Network or server issues"