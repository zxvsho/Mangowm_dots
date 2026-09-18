#!/bin/bash

# 获取mango命令输出并清理格式
output=$(mango -p 2>&1 | sed -r '
    s/\x1b\[[0-9;]*[a-zA-Z]//g   # 移除ANSI颜色代码
    s/   ╰─/ ╰─/g                # 压缩多余空格
    s/^[[:space:]]*//            # 删除行首空格
    s/[[:space:]]*$//            # 删除行尾空格
')


# 如果没有输出或输出为空，则退出
if [[ -z "$output" ]]; then
    exit 0
fi

# 发送通知
notify-send --urgency=critical --icon="$icon" "Mango Status" "$output"
