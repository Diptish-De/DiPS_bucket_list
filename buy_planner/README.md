To run your project from the terminal, you need to be in the folder where your `pubspec.yaml` file is located. 

Open your terminal (PowerShell or CMD) and run these steps:

1. **Navigate to the project folder:**
   ```powershell
   cd d:\repo\DiPS_bucket_list\buy_planner
   ```

2. **Run the app:**
   To run on your default device (like Chrome or Windows):
   ```powershell
   flutter run
   ```

### Quick Commands inside the terminal:
Once the app is running, you can use these keys in the terminal:
*   **`r`**: Hot Reload (updates the UI instantly without restarting).
*   **`R`**: Hot Restart (restarts the app from the beginning).
*   **`q`**: Quit (stops the program).

### Target specific devices:
If you have multiple devices connected (like your phone and a browser), you can specify which one to use:
*   **For Chrome:** `flutter run -d chrome`
*   **For Windows:** `flutter run -d windows`
*   **For your Android Phone:** `flutter run -d android` (Ensure your phone is connected via USB and "USB Debugging" is enabled).
