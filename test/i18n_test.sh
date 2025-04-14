#!/bin/bash
#
# 测试ShellCheck国际化功能是否正常工作
#

cd "$(dirname "$0")/.." || exit 1

echo "构建ShellCheck..."
cabal build

# 获取ShellCheck可执行文件路径
SHELLCHECK=$(find dist-newstyle -name shellcheck -type f -executable | head -n 1)

if [ -z "$SHELLCHECK" ]; then
    echo "错误: 找不到ShellCheck可执行文件"
    exit 1
fi

echo "使用ShellCheck: $SHELLCHECK"

# 创建测试脚本
cat > /tmp/test_script.sh << 'EOF'
#!/bin/bash
for f in $(ls *.txt)
do
  echo $f
done

echo $array
arr=(1 2 3)
arr=test

cd /some/dir
EOF

echo "=== 英文输出测试 ==="
$SHELLCHECK --lang=en /tmp/test_script.sh

echo ""
echo "=== 中文输出测试 ==="
$SHELLCHECK --lang=zh /tmp/test_script.sh

echo ""
echo "测试完成" 