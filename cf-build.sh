#!/bin/bash
set -e

# 1. 下载 Flutter SDK
git clone https://github.com/flutter/flutter.git -b stable --depth 1 ../flutter
export PATH="$PATH:$(pwd)/../flutter/bin"

# 2. 拉取私有库 nexa
git clone https://$DART_WORKFLOW_TRIGGER@github.com/u4-d/nexa.git ../nexa

# 3. 生成本地路径重写 pubspec_overrides.yaml
cat << 'EOF' > pubspec_overrides.yaml
dependency_overrides:
  models:
    path: ../nexa/packages/dart/models
  app_config:
    path: ../nexa/packages/dart/app_config
  my_supabase_service:
    path: ../nexa/packages/dart/my_supabase_service
  my_logger:
    path: ../nexa/packages/dart/my_logger
  my_analyzer:
    path: ../nexa/packages/dart/my_analyzer
  ranking:
    path: ../nexa/packages/flutter/stock/ranking
  utils:
    path: ../nexa/packages/dart/utils
EOF

# 4. 安装依赖并构建 Web
flutter pub get
flutter build web