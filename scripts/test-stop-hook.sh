#!/bin/bash
echo "Stop hook triggered at $(date)" >> /tmp/stop-hook-test.log
echo "CLAUDE_SESSION_ID: ${CLAUDE_SESSION_ID:-not set}" >> /tmp/stop-hook-test.log
echo "CLAUDE_PLUGIN_ROOT: ${CLAUDE_PLUGIN_ROOT:-not set}" >> /tmp/stop-hook-test.log
