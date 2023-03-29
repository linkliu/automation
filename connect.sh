#!/usr/bin/env bash

# 存放所有ovpn文件的目录
ovpn_dir="/path/to/ovpn/directory"

# 存放用户认证信息的文件
auth_file="/path/to/auth.txt"

# 存放临时日志的文件
log_file="/path/to/temp.log"

# 从auth_file中读取用户名和密码
read username password <<< $(cat ${auth_file})

# 遍历ovpn目录下的所有ovpn文件
for file in ${ovpn_dir}/*.ovpn; do
    echo "Trying ${file}..."

    # 删除旧的日志文件并创建新的
    rm -f ${log_file} && touch ${log_file}

    # 连接VPN并将所有日志重定向到临时日志文件
    sudo openvpn --config ${file} --auth-user-pass <(echo "${username}"; echo "${password}") &> ${log_file} &

    # 不停检测日志文件中是否出现成功连接的信息。如果连接成功，输出connect success!并等待用户输入stop，如果输入stop，则退出程序
    tail -f ${log_file} | while read line; do
        if echo "${line}" | grep -q "Initialization Sequence Completed"; then
            echo "connect success!"
            while true; do
                read -p "Input 'stop' to exit: " input
                if [ "${input}" == "stop" ]; then
                    echo "Exiting..."
                    kill $$
                    exit 0
                fi
            done
        fi
    done

    # 如果连VPN接失败，则提示connect fail!
    echo "connect fail!"
done
