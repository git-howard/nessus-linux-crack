#!/bin/bash

# Nessus 完整破解脚本
# 此脚本将完成离线注册、插件更新和配置修改，以绕过认证并获取完整扫描功能

# 检查是否以root用户运行
if [ "$(id -u)" -ne 0 ]; then
    echo "错误: 请以root用户身份运行此脚本"
    exit 1
fi

# 定义颜色变量
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
RESET="\033[0m"

# 定义文件路径变量
PLUGINS_FILE="./all-2.0.tar.gz"
PLUGIN_FEED_FILE="./plugin_feed_info.inc"

# 静默运行模式标志
SILENT_MODE=false
# 强制下载标志
FORCE_DOWNLOAD=false

# 记录脚本开始时间
SCRIPT_START_TIME=$(date +%s)

# 计时函数
log_step_time() {
    local step_name="$1"
    local step_start_time="$2"
    local current_time=$(date +%s)
    local step_duration=$((current_time - step_start_time))
    local total_duration=$((current_time - SCRIPT_START_TIME))
    
    echo -e "${BLUE}[计时] $step_name: ${step_duration}秒 (总耗时: ${total_duration}秒)${RESET}"
}

# 打印欢迎信息
print_welcome() {
    if [ "$SILENT_MODE" = false ]; then
        echo -e "${GREEN}"
        echo "=================================================="
        echo "|                                                |"
        echo "|            Nessus 完整破解脚本                 |"
        echo "|           绕过在线认证，获取扫描功能           |"
        echo "=================================================="
        echo -e "${RESET}"
    else
        echo -e "${GREEN}静默模式: Nessus 完整破解脚本${RESET}"
    fi
}

# 检查Nessus是否已安装
check_nessus_installed() {
    if [ ! -d "/opt/nessus" ]; then
        if [ "$SILENT_MODE" = false ]; then
            echo -e "${RED}错误: 未检测到Nessus安装。请先安装Nessus。${RESET}"
        else
            echo -e "${RED}静默模式: 错误: 未检测到Nessus安装。请先安装Nessus。${RESET}"
        fi
        exit 1
    fi
    if [ "$SILENT_MODE" = false ]; then
        echo -e "${GREEN}✓ 已检测到Nessus安装${RESET}"
    else
        echo -e "${GREEN}静默模式: 已检测到Nessus安装${RESET}"
    fi
}

# 检查必要文件是否存在
check_required_files() {
    local step_start_time=$(date +%s)
    if [ "$SILENT_MODE" = false ]; then
        echo -e "${BLUE}检查必要的破解文件...${RESET}"
    fi
    
    # 检查插件包文件
    if [ ! -f "$PLUGINS_FILE" ] || [ "$FORCE_DOWNLOAD" = true ]; then
        if [ "$FORCE_DOWNLOAD" = true ] && [ -f "$PLUGINS_FILE" ]; then
            if [ "$SILENT_MODE" = false ]; then
                echo -e "${YELLOW}强制模式: 将重新下载插件包文件...${RESET}"
            else
                echo -e "${BLUE}静默模式: 强制重新下载插件包文件...${RESET}"
            fi
        elif [ ! -f "$PLUGINS_FILE" ]; then
            if [ "$SILENT_MODE" = false ]; then
                echo -e "${YELLOW}警告: 插件包文件不存在: $PLUGINS_FILE${RESET}"
                echo -e "${YELLOW}是否需要下载插件包文件? (y/n)${RESET}"
                read -r download_choice
            else
                echo -e "${BLUE}静默模式: 自动下载插件包文件...${RESET}"
                download_choice="y"
            fi
        fi
        
        if [[ "$download_choice" =~ ^[Yy]$ ]] || [ "$FORCE_DOWNLOAD" = true ]; then
            if [ "$SILENT_MODE" = false ]; then
                echo -e "${BLUE}正在下载插件包文件...${RESET}"
            else
                echo -e "${BLUE}静默模式: 正在下载插件包文件...${RESET}"
            fi
            curl -A Mozilla -o "$PLUGINS_FILE" --url "https://plugins.nessus.org/v2/nessus.php?f=all-2.0.tar.gz&u=29fc85234e4cd7e636ae8e9232c55313&p=33e0396a01619108b7be1bb78954c458"
            if [ $? -eq 0 ]; then
                if [ "$SILENT_MODE" = false ]; then
                    echo -e "${GREEN}✓ 插件包文件下载成功${RESET}"
                else
                    echo -e "${GREEN}静默模式: 插件包文件下载成功${RESET}"
                fi
            else
                if [ "$SILENT_MODE" = false ]; then
                    echo -e "${RED}错误: 插件包文件下载失败${RESET}"
                else
                    echo -e "${RED}静默模式: 插件包文件下载失败，退出${RESET}"
                fi
                exit 1
            fi
        else
            if [ "$SILENT_MODE" = false ]; then
                echo -e "${RED}错误: 缺少必要文件，无法继续${RESET}"
            fi
            exit 1
        fi
    else
        # 检查文件日期
        file_date=$(stat -c %Y "$PLUGINS_FILE" 2>/dev/null)
        current_date=$(date +%s)
        days_diff=$(( (current_date - file_date) / 86400 ))
        
        if [ $days_diff -gt 15 ]; then
            if [ "$SILENT_MODE" = false ]; then
                echo -e "${YELLOW}警告: 插件包文件已存在，但已超过15天 (${days_diff}天)${RESET}"
                echo -e "${YELLOW}是否需要重新下载插件包文件? (y/n)${RESET}"
                read -r redownload_choice
            else
                echo -e "${BLUE}静默模式: 插件包文件已超过15天，自动重新下载...${RESET}"
                redownload_choice="y"
            fi
            
            if [[ "$redownload_choice" =~ ^[Yy]$ ]]; then
                if [ "$SILENT_MODE" = false ]; then
                    echo -e "${BLUE}正在重新下载插件包文件...${RESET}"
                else
                    echo -e "${BLUE}静默模式: 正在重新下载插件包文件...${RESET}"
                fi
                curl -A Mozilla -o "$PLUGINS_FILE" --url "https://plugins.nessus.org/v2/nessus.php?f=all-2.0.tar.gz&u=29fc85234e4cd7e636ae8e9232c55313&p=33e0396a01619108b7be1bb78954c458"
                if [ $? -eq 0 ]; then
                    if [ "$SILENT_MODE" = false ]; then
                        echo -e "${GREEN}✓ 插件包文件重新下载成功${RESET}"
                    else
                        echo -e "${GREEN}静默模式: 插件包文件重新下载成功${RESET}"
                    fi
                else
                    if [ "$SILENT_MODE" = false ]; then
                        echo -e "${RED}错误: 插件包文件重新下载失败，将使用现有文件${RESET}"
                    else
                        echo -e "${YELLOW}静默模式: 插件包文件重新下载失败，将使用现有文件${RESET}"
                    fi
                fi
            fi
        else
            if [ "$SILENT_MODE" = false ]; then
                echo -e "${GREEN}✓ 插件包文件检查通过 (${days_diff}天前创建)${RESET}"
            else
                echo -e "${GREEN}静默模式: 插件包文件检查通过 (${days_diff}天前创建)${RESET}"
            fi
        fi
    fi
    
    # 检查plugin_feed_info.inc文件
    if [ ! -f "$PLUGIN_FEED_FILE" ]; then
        if [ "$SILENT_MODE" = false ]; then
            echo -e "${RED}错误: plugin_feed_info.inc文件不存在: $PLUGIN_FEED_FILE${RESET}"
            echo -e "${YELLOW}请确保plugin_feed_info.inc文件在当前目录下${RESET}"
        else
            echo -e "${RED}静默模式: 错误: plugin_feed_info.inc文件不存在: $PLUGIN_FEED_FILE${RESET}"
        fi
        exit 1
    fi
    
    if [ "$SILENT_MODE" = false ]; then
        echo -e "${GREEN}✓ 所有必要文件检查通过${RESET}"
        echo -e "${BLUE}使用插件包: $PLUGINS_FILE${RESET}"
        echo -e "${BLUE}使用配置文件: $PLUGIN_FEED_FILE${RESET}"
    else
        echo -e "${GREEN}静默模式: 所有必要文件检查通过${RESET}"
    fi
    
    log_step_time "检查必要文件" "$step_start_time"
}

# 停止Nessus服务
stop_nessus_service() {
    if [ "$SILENT_MODE" = false ]; then
        echo -e "${BLUE}正在停止Nessus服务...${RESET}"
    else
        echo -e "${BLUE}静默模式: 正在停止Nessus服务...${RESET}"
    fi
    systemctl stop nessusd.service > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        if [ "$SILENT_MODE" = false ]; then
            echo -e "${GREEN}✓ Nessus服务已停止${RESET}"
        else
            echo -e "${GREEN}静默模式: Nessus服务已停止${RESET}"
        fi
    else
        if [ "$SILENT_MODE" = false ]; then
            echo -e "${YELLOW}警告: 无法停止Nessus服务，可能已经停止${RESET}"
        else
            echo -e "${YELLOW}静默模式: 无法停止Nessus服务，可能已经停止${RESET}"
        fi
    fi
}



# 清理现有插件目录
clean_plugin_directory() {
    local step_start_time=$(date +%s)
    if [ "$SILENT_MODE" = false ]; then
        echo -e "${BLUE}正在清理现有插件目录...${RESET}"
    else
        echo -e "${BLUE}静默模式: 正在清理现有插件目录...${RESET}"
    fi
    
    # 停止Nessus服务（确保没有进程在使用插件）
    systemctl stop nessusd.service > /dev/null 2>&1
      
    # 移除目录及其所有内容的不可变属性（如果存在）
    if [ "$SILENT_MODE" = false ]; then
        echo -e "${YELLOW}清理当前插件目录...${RESET}"
    fi
    find /opt/nessus/lib/nessus/plugins/ -type f -exec chattr -i {} \; > /dev/null 2>&1
    chattr -i /opt/nessus/lib/nessus/plugins > /dev/null 2>&1
    
    # 删除整个插件目录
    rm -rf /opt/nessus/lib/nessus/plugins > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        if [ "$SILENT_MODE" = false ]; then
            echo -e "${GREEN}✓ 插件目录删除成功${RESET}"
        else
            echo -e "${GREEN}静默模式: 插件目录删除成功${RESET}"
        fi
    else
        if [ "$SILENT_MODE" = false ]; then
            echo -e "${YELLOW}警告: 插件目录删除可能不完全，尝试强制删除...${RESET}"
        else
            echo -e "${YELLOW}静默模式: 插件目录删除可能不完全，尝试强制删除...${RESET}"
        fi
        # 尝试使用find命令强制删除
        find /opt/nessus/lib/nessus/ -name "plugins" -type d -exec rm -rf {} \; > /dev/null 2>&1
    fi
    
    # 重建插件目录
    if [ "$SILENT_MODE" = false ]; then
        echo -e "${YELLOW}重建插件目录...${RESET}"
    fi
    mkdir -p /opt/nessus/lib/nessus/plugins
    
    # 设置正确的目录权限
    chown -R nessus:nessus /opt/nessus/lib/nessus/plugins > /dev/null 2>&1
    chmod 755 /opt/nessus/lib/nessus/plugins > /dev/null 2>&1
    
    if [ "$SILENT_MODE" = false ]; then
        echo -e "${GREEN}✓ 插件目录重建完成${RESET}"
    else
        echo -e "${GREEN}静默模式: 插件目录重建完成${RESET}"
    fi
    
    log_step_time "清理插件目录" "$step_start_time"
}

# 离线更新插件
update_plugins() {
    local step_start_time=$(date +%s)
    if [ "$SILENT_MODE" = false ]; then
        echo -e "${BLUE}正在更新插件...${RESET}"
        echo -e "${YELLOW}注意: 此过程可能需要较长时间，请耐心等待...${RESET}"
    else
        echo -e "${BLUE}静默模式: 正在更新插件...${RESET}"
    fi
    /opt/nessus/sbin/nessuscli update "$PLUGINS_FILE"
    if [ $? -eq 0 ]; then
        if [ "$SILENT_MODE" = false ]; then
            echo -e "${GREEN}✓ 插件更新成功${RESET}"
        else
            echo -e "${GREEN}静默模式: 插件更新成功${RESET}"
        fi
    else
        if [ "$SILENT_MODE" = false ]; then
            echo -e "${RED}错误: 插件更新失败${RESET}"
        else
            echo -e "${RED}静默模式: 插件更新失败${RESET}"
        fi
        exit 1
    fi
    
    log_step_time "更新插件" "$step_start_time"
}

# 设置插件文件为只读
set_plugins_readonly() {
    local step_start_time=$(date +%s)
    if [ "$SILENT_MODE" = false ]; then
        echo -e "${BLUE}正在设置插件文件为只读...${RESET}"
        echo -e "${YELLOW}注意: 此过程可能需要较长时间，因为插件数量超过15万个...${RESET}"
    else
        echo -e "${BLUE}静默模式: 正在设置插件文件为只读...${RESET}"
    fi
    find /opt/nessus/lib/nessus/plugins/ -name "*.*" | xargs -i chattr +i {}
    if [ $? -eq 0 ]; then
        if [ "$SILENT_MODE" = false ]; then
            echo -e "${GREEN}✓ 插件文件已设置为只读${RESET}"
        else
            echo -e "${GREEN}静默模式: 插件文件已设置为只读${RESET}"
        fi
    else
        if [ "$SILENT_MODE" = false ]; then
            echo -e "${RED}错误: 设置插件文件只读失败${RESET}"
        else
            echo -e "${RED}静默模式: 设置插件文件只读失败${RESET}"
        fi
        exit 1
    fi
    
    log_step_time "设置插件文件只读" "$step_start_time"
}

# 取消plugin_feed_info.inc文件的只读属性
unset_plugin_feed_readonly() {
    if [ "$SILENT_MODE" = false ]; then
        echo -e "${BLUE}正在取消plugin_feed_info.inc文件的只读属性...${RESET}"
    else
        echo -e "${BLUE}静默模式: 正在取消plugin_feed_info.inc文件的只读属性...${RESET}"
    fi
    # 检查文件是否存在
    if [ -f "/opt/nessus/lib/nessus/plugins/plugin_feed_info.inc" ]; then
        chattr -i /opt/nessus/lib/nessus/plugins/plugin_feed_info.inc  > /dev/null 2>&1
		rm -f /opt/nessus/lib/nessus/plugins/plugin_feed_info.inc  > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            if [ "$SILENT_MODE" = false ]; then
                echo -e "${GREEN}✓ 已取消plugin_feed_info.inc文件的只读属性${RESET}"
            else
                echo -e "${GREEN}静默模式: 已取消plugin_feed_info.inc文件的只读属性${RESET}"
            fi
        else
            if [ "$SILENT_MODE" = false ]; then
                echo -e "${YELLOW}警告: 无法取消plugin_feed_info.inc文件的只读属性${RESET}"
            else
                echo -e "${YELLOW}静默模式: 无法取消plugin_feed_info.inc文件的只读属性${RESET}"
            fi
        fi
    else
        if [ "$SILENT_MODE" = false ]; then
            echo -e "${YELLOW}注意: plugin_feed_info.inc文件不存在，跳过取消只读属性步骤${RESET}"
        else
            echo -e "${YELLOW}静默模式: plugin_feed_info.inc文件不存在，跳过取消只读属性步骤${RESET}"
        fi
    fi
}

# 获取PLUGIN_SET数字
get_plugin_set() {
    if [ "$SILENT_MODE" = false ]; then
        echo -e "${BLUE}从当前目录的plugin_feed_info.inc文件获取PLUGIN_SET数字...${RESET}"
    else
        echo -e "${BLUE}静默模式: 从当前目录的plugin_feed_info.inc文件获取PLUGIN_SET数字...${RESET}"
    fi
    if [ -f "$PLUGIN_FEED_FILE" ]; then
        PLUGIN_SET=$(grep "PLUGIN_SET" "$PLUGIN_FEED_FILE" | sed 's/PLUGIN_SET = "\(.*\)";/\1/')
        if [ "$SILENT_MODE" = false ]; then
            echo -e "${GREEN}✓ 获取到PLUGIN_SET: $PLUGIN_SET${RESET}"
        else
            echo -e "${GREEN}静默模式: 获取到PLUGIN_SET: $PLUGIN_SET${RESET}"
        fi
    else
        if [ "$SILENT_MODE" = false ]; then
            echo -e "${RED}错误: 无法找到当前目录下的plugin_feed_info.inc文件${RESET}"
        else
            echo -e "${RED}静默模式: 错误: 无法找到当前目录下的plugin_feed_info.inc文件${RESET}"
        fi
        exit 1
    fi
}

# 配置plugin_feed_info.inc文件
configure_plugin_feed_files() {
    local step_start_time=$(date +%s)
    if [ "$SILENT_MODE" = false ]; then
        echo -e "${BLUE}正在配置plugin_feed_info.inc文件...${RESET}"
    else
        echo -e "${BLUE}静默模式: 正在配置plugin_feed_info.inc文件...${RESET}"
    fi
    
    # 确保目录存在并设置正确的权限
    mkdir -p /opt/nessus/lib/nessus/plugins
    mkdir -p /opt/nessus/var/nessus/plugins
	chattr -i /opt/nessus/lib/nessus/plugins/plugin_feed_info.inc
	chattr -i /opt/nessus/var/nessus/plugin_feed_info.inc
 	rm -f /opt/nessus/lib/nessus/plugins/plugin_feed_info.inc
	rm -f /opt/nessus/var/nessus/plugin_feed_info.inc   
    # 复制当前目录的plugin_feed_info.inc到系统位置
    cp "$PLUGIN_FEED_FILE" /opt/nessus/lib/nessus/plugins/plugin_feed_info.inc  > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        if [ "$SILENT_MODE" = false ]; then
            echo -e "${RED}错误: 无法复制文件到/opt/nessus/lib/nessus/plugins/，尝试修改权限后重试${RESET}"
        else
            echo -e "${RED}静默模式: 无法复制文件到/opt/nessus/lib/nessus/plugins/，尝试修改权限后重试${RESET}"
        fi
        chmod 755 /opt/nessus/lib/nessus/plugins
        cp "$PLUGIN_FEED_FILE" /opt/nessus/lib/nessus/plugins/plugin_feed_info.inc  > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            if [ "$SILENT_MODE" = false ]; then
                echo -e "${RED}错误: 仍然无法复制文件，请检查权限${RESET}"
            else
                echo -e "${RED}静默模式: 仍然无法复制文件，请检查权限${RESET}"
            fi
            exit 1
        fi
    fi
    
    # 尝试复制到/var/nessus目录
    cp "$PLUGIN_FEED_FILE" /opt/nessus/var/nessus/plugin_feed_info.inc
    if [ $? -ne 0 ]; then
        if [ "$SILENT_MODE" = false ]; then
            echo -e "${YELLOW}警告: 无法复制文件到/opt/nessus/var/nessus/，尝试修改权限后重试${RESET}"
        else
            echo -e "${YELLOW}静默模式: 无法复制文件到/opt/nessus/var/nessus/，尝试修改权限后重试${RESET}"
        fi
        chmod 755 /opt/nessus/var/nessus
        cp "$PLUGIN_FEED_FILE" /opt/nessus/var/nessus/plugin_feed_info.inc > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            if [ "$SILENT_MODE" = false ]; then
                echo -e "${YELLOW}警告: 仍然无法复制文件到/var/nessus，但继续执行${RESET}"
            else
                echo -e "${YELLOW}静默模式: 仍然无法复制文件到/var/nessus，但继续执行${RESET}"
            fi
        fi
    fi
    
    # 设置该文件只读（如果复制成功）
    if [ -f "/opt/nessus/var/nessus/plugin_feed_info.inc" ]; then
        chattr +i /opt/nessus/var/nessus/plugin_feed_info.inc  > /dev/null 2>&1
    fi
    
    # 创建plugins目录并复制文件
    cd /opt/nessus/var/nessus/
    mkdir -p plugins
    cp plugin_feed_info.inc plugins/ 2>/dev/null
    
    # 设置正确的文件所有权
    chown -R nessus:nessus /opt/nessus/lib/nessus/plugins > /dev/null 2>&1
    chown -R nessus:nessus /opt/nessus/var/nessus > /dev/null 2>&1
    
    if [ "$SILENT_MODE" = false ]; then
        echo -e "${GREEN}✓ 配置文件修改完成${RESET}"
    else
        echo -e "${GREEN}静默模式: 配置文件修改完成${RESET}"
    fi
    
    log_step_time "配置plugin_feed_info.inc文件" "$step_start_time"
}

# 启动Nessus服务
start_nessus_service() {
    if [ "$SILENT_MODE" = false ]; then
        echo -e "${BLUE}正在启动Nessus服务...${RESET}"
    else
        echo -e "${BLUE}静默模式: 正在启动Nessus服务...${RESET}"
    fi
    systemctl start nessusd.service
    if [ $? -eq 0 ]; then
        if [ "$SILENT_MODE" = false ]; then
            echo -e "${GREEN}✓ Nessus服务已启动${RESET}"
        else
            echo -e "${GREEN}静默模式: Nessus服务已启动${RESET}"
        fi
    else
        if [ "$SILENT_MODE" = false ]; then
            echo -e "${RED}错误: 无法启动Nessus服务${RESET}"
            echo -e "${YELLOW}请尝试手动启动Nessus服务: systemctl start nessusd${RESET}"
        else
            echo -e "${RED}静默模式: 无法启动Nessus服务${RESET}"
        fi
    fi
}

# 显示完成信息
show_completion_info() {
    local step_start_time=$(date +%s)
    local total_duration=$((step_start_time - SCRIPT_START_TIME))
    local minutes=$((total_duration / 60))
    local seconds=$((total_duration % 60))
    
    if [ "$SILENT_MODE" = false ]; then
        echo -e "\n${GREEN}==================================================${RESET}"
        echo -e "${GREEN}Nessus破解已完成!${RESET}"
        echo -e "${YELLOW}注意: 请等待几分钟让Nessus完全加载所有插件。${RESET}"
        
        # 获取本机IP地址
        LOCAL_IP=$(ip route get 1 | awk '{print $7}' | head -1)
        if [ -z "$LOCAL_IP" ]; then
            # 如果上述方法失败，尝试其他方法
            LOCAL_IP=$(hostname -I | awk '{print $1}')
        fi
        if [ -z "$LOCAL_IP" ]; then
            # 如果还是获取不到，使用localhost
            LOCAL_IP="localhost"
        fi
        
        echo -e "${BLUE}访问 ${RED}https://$LOCAL_IP:8834 ${BLUE}登录Nessus Web界面${RESET}"
        
        # 显示总执行时间
        echo -e "\n${BLUE}==================== 执行时间统计 ====================${RESET}"
        echo -e "${GREEN}总执行时间: ${minutes}分${seconds}秒 (${total_duration}秒)${RESET}"
        echo -e "${GREEN}==================================================${RESET}\n"
    else
        echo -e "\n${GREEN}静默模式: Nessus破解已完成!${RESET}"
        echo -e "${BLUE}静默模式: 总执行时间: ${minutes}分${seconds}秒 (${total_duration}秒)${RESET}"
    fi
}

# 显示帮助信息
show_help() {
    echo -e "${BLUE}Nessus 离线破解脚本${RESET}"
    echo -e "${BLUE}===================${RESET}"
    echo ""
    echo -e "${YELLOW}用法: $0 [选项]${RESET}"
    echo ""
    echo -e "${YELLOW}选项:${RESET}"
    echo -e "  -h, --help    显示此帮助信息"
    echo -e "  -s, --silent  静默模式，自动下载插件包并执行更新"
    echo -e "  -f, --force   强制下载插件包，即使文件存在且未过期"
    echo ""
    echo -e "${YELLOW}功能:${RESET}"
    echo "  - 自动检查并下载插件包文件（如果不存在或超过15天）"
    echo "  - 清理并重建插件目录"
    echo "  - 更新插件"
    echo "  - 设置插件文件只读权限"
    echo "  - 配置plugin_feed_info.inc文件"
    echo "  - 自动管理Nessus服务"
    echo ""
    echo -e "${YELLOW}所需文件:${RESET}"
    echo "  - plugin_feed_info.inc (Nessus配置文件)"
    echo "  - all-2.0.tar.gz (插件包文件，如果不存在将提示下载)"
    echo ""
    echo -e "${YELLOW}注意事项:${RESET}"
    echo "  - 脚本将跳过离线注册步骤，请确保Nessus已正确注册"
    echo "  - 如需手动注册，请使用: /opt/nessus/sbin/nessuscli fetch --register <许可证文件>"
    echo "  - 请确保plugin_feed_info.inc文件存在于脚本所在目录中"
    echo "  - 插件包文件如果不存在或超过15天，脚本将提示是否下载"
    echo "  - 静默模式下，脚本会自动下载插件包并执行所有更新步骤"
    echo "  - 静默模式适用于自动化部署场景"
    echo "  - 强制下载模式会忽略文件存在性和时间检查，直接重新下载"
    echo ""
    echo -e "${YELLOW}示例:${RESET}"
    echo "  $0                    # 执行完整流程"
    echo "  $0 --help             # 显示此帮助信息"
    echo "  $0 --silent           # 静默模式执行"
    echo "  $0 --silent --force   # 静默模式强制下载插件包"
}

# 解析命令行参数
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -s|--silent)
                SILENT_MODE=true
                shift
                ;;
            -f|--force)
                FORCE_DOWNLOAD=true
                shift
                ;;
            *)
                echo -e "${RED}未知参数: $1${RESET}"
                show_help
                exit 1
                ;;
        esac
    done
}

# 主函数
main() {
    print_welcome
    parse_args "$@"
    check_nessus_installed
    check_required_files
    stop_nessus_service
    clean_plugin_directory
    update_plugins
    set_plugins_readonly
    unset_plugin_feed_readonly
    get_plugin_set
    configure_plugin_feed_files
    start_nessus_service
    show_completion_info
}

# 执行主函数
main "$@"
