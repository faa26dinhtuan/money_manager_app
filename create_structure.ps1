# Tạo cây thư mục Flutter chuẩn (Windows PowerShell).
# Chạy ở thư mục gốc project (nơi có pubspec.yaml):
#   powershell -ExecutionPolicy Bypass -File .\create_structure.ps1

$dirs = @(
  "lib/core/theme",
  "lib/core/widgets",
  "lib/core/utils",
  "lib/data/models",
  "lib/data/services",
  "lib/features/home/widgets",
  "lib/features/search",
  "lib/features/profile",
  "assets/images",
  "assets/icons",
  "assets/fonts"
)

foreach ($d in $dirs) {
  New-Item -ItemType Directory -Force -Path $d | Out-Null
  New-Item -ItemType File -Force -Path "$d/.gitkeep" | Out-Null  # để git không bỏ qua folder rỗng
}

Write-Host "Xong! Đã tạo $($dirs.Count) thư mục."
