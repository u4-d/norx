#!/bin/bash
set -e

# 1. 下载 Flutter SDK (浅克隆)
if [ ! -d "../flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 ../flutter
fi
export PATH="$PATH:$(pwd)/../flutter/bin"

# 2. 【核心优化】对 nexa 进行稀疏检出 (Sparse Checkout)
echo "==> Performing sparse checkout for nexa..."
# 保存初始的项目路径（无论在本地叫 norx 还是在 Cloudflare 叫 repo）
ORIGIN_DIR=$(pwd)

mkdir -p ../nexa
cd ../nexa
git init
git config core.sparseCheckout true

# 设定只拉取 norx 依赖的 packages 路径（按需添加文件夹）
cat << 'EOF' > .git/info/sparse-checkout
packages/dart/models
packages/dart/app_config
packages/dart/my_supabase_service
packages/dart/my_logger
packages/dart/my_analyzer
packages/dart/utils
packages/flutter/stock/ranking
EOF

# 配置远程仓库并仅拉取 main 分支最新 1 次 Commit
git remote add origin https://$DART_WORKFLOW_TRIGGER@github.com/u4-d/nexa.git
git pull --depth 1 origin main
# 【关键修改】切回原项目目录，不再写死 norx
cd "$ORIGIN_DIR"

# 3. 动态生成本地路径重写 pubspec_overrides.yaml
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

# 4. 安装依赖并编译 Web
flutter pub get
flutter build web