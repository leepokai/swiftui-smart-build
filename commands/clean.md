---
description: Clean Xcode derived data and build artifacts
---

Clean the Xcode build cache by removing derived data for the current project.

## Steps

1. First, read `.smart-build.json` to get the project configuration
2. Run the following command to clean derived data:
   ```bash
   xcodebuild clean -scheme "<SCHEME_NAME>" -destination "<DESTINATION>"
   ```
3. Optionally, if the user requests a deep clean, also remove the DerivedData folder:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/<PROJECT_NAME>-*
   ```

After cleaning, report the result to the user.
