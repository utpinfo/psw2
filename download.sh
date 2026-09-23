#!/bin/bash

# 檢查參數
[ $# -gt 2 ] && {
  echo "使用方法: $0 <版本> <架構>"
  echo "示例1: $0 25.7.15-1"
  echo "示例2: $0 25.7.15-1 aarch64_generic"
  echo "示例3: $0 25.7.15-1 aarch64_cortex-a53"
  echo "示例4: $0 25.7.15-1 x86_64"    
  exit 1
}

version_latest=$(curl -s https://api.github.com/repositories/466781739/releases/latest | grep tag_name | cut -d'"' -f4)
version="${1:-$version_latest}"

arch_os=$(grep 'OPENWRT_ARCH' /etc/os-release | cut -d'=' -f2 | tr -d '"')
arch="${2:-$arch_os}"
err=0

list_url="https://github.com/Openwrt-Passwall/openwrt-passwall2/releases/expanded_assets/${version}/"
base_url="https://github.com/Openwrt-Passwall/openwrt-passwall2/releases/download/${version}/"
echo "⬇️ url: ${list_url}"
mkdir -p "./${arch}"
rm -rf "./${arch}"/*


files=(
  "luci-app-passwall2_"
  "luci-i18n-passwall2-zh-cn_"
  "packages_ipk_${arch}"
)

for item in "${files[@]}"; do
  file=$(curl -s "$list_url" | grep -oE "[^/]*${item}[^/]*\.(ipk|zip)" | head -n 1)
  echo "⬇️ 檔名: ${file}"
  [ -z "$file" ] && { echo "❌ 找不到檔案: ${item}"; ((err++)); continue; }

  download_url="${base_url}${file}"
  target_path="./${arch}/${file}"

  echo "⬇️ 地址: $download_url"
  curl -sL -o "$target_path" "$download_url" || { echo "❌ 下載失敗: $file"; ((err++)); continue; }
  [ ! -s "$target_path" ] && { echo "❌ 檔案為空: $file"; ((err++)); continue; }

  echo "✅ 完成: $file"

  [[ "$file" == *.zip ]] && {
    unzip -tq "$target_path" > /dev/null 2>&1 && unzip -q "$target_path" -d "./${arch}/" && echo "📦 解壓完成: $file" || echo "⚠️ 無效 ZIP: $file"
  }
done

exit $err