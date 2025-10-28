#!/usr/bin/env bash
set -e  # 可选：出错立即退出，可去掉如果想继续执行后续测试

# 获取当前工作目录
home=$PWD

# ===== 1. 运行 API 测试 =====
cd test_apis
bash ./run.sh
api=$?
echo "api exit code: ${api}"
cd $home

# ===== 2. 运行 Model/Example 测试 =====
cd test_models
bash ./run.sh
example=$?
echo "example exit code: ${example}"
cd $home

# ===== 3. 运行 pytest 测试 =====
echo "running pytest..."
pytest_log="pytest_result.txt"
python -m pytest ../test --maxfail=1 --disable-warnings -q | tee ${pytest_log}
pytest_ret=${PIPESTATUS[0]}
echo "pytest exit code: ${pytest_ret}"

# ===== 4. 输出结果汇总 =====
echo "=============== result ================="
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"

total=$((api + example + pytest_ret))

if [ ${total} -eq 0 ]; then
  # 全部通过
  echo "All tests passed!"
  result_files=$(find . -name "result.txt" -o -name "pytest_result.txt")
  for file in ${result_files}; do
      echo "------ ${file} ------"
      cat "${file}"
      echo "------------------------"
  done
  echo -e "\033[32msuccess!\033[0m"
else
  # 有失败
  echo "Some tests failed!"
  result_files=$(find . -name "result.txt" -o -name "pytest_result.txt")
  for file in ${result_files}; do
      echo "------ ${file} ------"
      cat "${file}"
      echo "------------------------"
  done
  echo -e "\033[31merror!\033[0m"
fi

echo "Total exit code: ${total}"
exit ${total}
