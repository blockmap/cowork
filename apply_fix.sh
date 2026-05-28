#!/bin/bash
# apply_fix.sh - 正确应用模型名称转换修复

cd /Users/block/code/cowork

# 定位需要修改的文件
FILE="rust/crates/api/src/providers/openai_compat.rs"

# 备份原始文件
cp "$FILE" "$FILE.bak"

# 使用 awk 精确修改第 958 行（修复自定义 base_url 时的模型名称处理）
awk 'NR == 958 { sub(/return Cow::Borrowed(model);/, "return Cow::Borrowed(&model[pos + 1..]);") } 1' "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"

echo "修复已应用！"
echo ""
echo "检查修改："
grep -n "return Cow::Borrowed(&model\[pos" "$FILE"