## In-Line Data Scanner

```dart
SizedBox(
  height: 250,
  width: 400,
  child: DataScanner( /* ... */ ),
)
```

## Full Page Data Scanner

If you want a full-page scanner, you can use the `DataScannerPage` widget instead.

```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => DataScannerPage( /* ... */ ),
  ),
);
```