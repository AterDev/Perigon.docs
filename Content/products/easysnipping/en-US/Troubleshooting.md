# Troubleshooting

## The shortcut does not respond

Confirm that EasySnipping is running in the system tray, then check whether another application already owns the shortcut. Choose a different combination and save it. Windows may also restrict global input access when another application runs with higher privileges.

## Smart selection does not find the exact control

Some elevated, custom-drawn, or specially rendered windows do not expose an accessible control boundary. Wait for the candidate to finish, or drag a free-form selection. EasySnipping keeps a window fallback or free-form selection available when exact detection is not possible.

## OCR is unavailable or incomplete

Check that Windows has an OCR language pack matching the text, then choose that language or automatic selection in Advanced settings. Low-resolution or blurred text, complex backgrounds, and very small regions can reduce recognition quality.

## The screenshot position or colors look wrong

Multiple monitors, display scaling, and special window rendering can affect some applications. Check Windows display settings and capture again. If automatic selection is unexpected, use a free-form drag.

## Remove local data

Delete exported screenshots manually from the save directory; clipboard contents are managed by Windows. Preferences are stored in `%LocalAppData%\Snipping\settings.ini`. Uninstalling the app does not automatically remove screenshots you exported.
