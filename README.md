# Nessus 完整破解脚本

这是一个用于绕过Nessus在线认证，获取完整扫描功能的Shell脚本。脚本会自动下载最新插件包，配置必要文件，并启动Nessus服务。

## 功能特点

- 自动下载最新的Nessus插件包
- 绕过Nessus在线认证限制
- 配置plugin_feed_info.inc文件
- 自动安装和更新插件
- 提供详细的日志输出和调试信息
- 支持静默模式和调试模式

## 系统要求

- Linux操作系统
- 已安装Nessus扫描器
- 具有sudo权限（如果不是root用户）
- 已安装curl、systemctl等基本命令

## 使用方法

### 基本使用

```bash
# 给脚本添加执行权限
chmod +x nessus_crack_complete.sh

# 运行脚本
sudo ./nessus_crack_complete.sh
```

### 命令行参数

```bash
# 显示帮助信息
./nessus_crack_complete.sh -h 或 ./nessus_crack_complete.sh --help

# 静默模式（自动下载插件包并执行更新，无需用户交互）
./nessus_crack_complete.sh -s 或 ./nessus_crack_complete.sh --silent

# 强制下载插件包（即使文件存在且未过期）
./nessus_crack_complete.sh -f 或 ./nessus_crack_complete.sh --force

# 启用调试模式（输出详细调试信息）
./nessus_crack_complete.sh -d 或 ./nessus_crack_complete.sh --debug

# 组合使用多个参数
./nessus_crack_complete.sh -s -d  # 静默模式+调试模式
```

## 脚本执行流程

1. **环境检查**：检查Nessus是否已安装
2. **创建配置文件**：检查并创建内置plugin_feed_info.inc文件
3. **插件版本检查**：检查当前插件版本
4. **文件检查**：检查必要的破解文件是否存在
5. **服务停止**：停止Nessus服务
6. **目录清理**：清理并重建插件目录（不备份原文件）
7. **插件更新**：下载并更新插件包，执行nessuscli update命令
8. **权限设置**：设置插件文件为只读
9. **配置文件**：配置plugin_feed_info.inc文件（直接替换原文件）
10. **服务启动**：启动Nessus服务

## 重要说明

### 关于文件备份

- **原系统文件不会被备份**：脚本会直接删除原系统的plugin_feed_info.inc文件和plugins目录，不进行备份操作
- **插件升级命令**：脚本会执行`/opt/nessus/sbin/nessuscli update "$PLUGINS_FILE"`命令来升级插件

### 日志和调试

- 脚本会生成详细的日志记录，包括每个步骤的执行时间
- 使用`-d`或`--debug`参数可以启用调试模式，获取更详细的执行信息
- 日志文件保存在脚本执行目录中，便于问题排查

### 注意事项

1. **权限要求**：脚本需要root权限或sudo权限来修改Nessus系统文件
2. **服务中断**：执行过程中会停止和重启Nessus服务，请确保在合适的时间执行
3. **插件更新**：插件更新过程可能需要较长时间，请耐心等待，如果更新失败，可能是链接失效，自行更新下载链接，程序中curl 部分。
4. **网络连接**：需要稳定的网络连接来下载插件包


## 常见问题

### Q: 脚本执行失败怎么办？

A: 请检查以下几点：
- 确保已安装Nessus
- 确保有足够的权限（使用sudo）
- 检查网络连接是否正常
- 使用`-d`参数启用调试模式查看详细错误信息

### Q: 插件更新失败怎么办？

A: 可能的原因和解决方法：
- 检查插件包文件是否完整下载
- 尝试使用`-f`参数强制重新下载插件包
- 手动执行`/opt/nessus/sbin/nessuscli update "插件包路径"`命令

### Q: 如何验证破解是否成功？

A: 破解成功后，您应该能够：
- 无需登录即可使用Nessus的全部扫描功能
- 看到插件已更新到最新版本
- 在Nessus Web界面中看到"ProfessionalFeed (Direct)"的插件源

## 文件结构

```
nessus_crack_complete.sh    # 主脚本文件
plugin_feed_info.inc        # 插件配置文件（脚本会自动创建）
```

## 更新日志

- v1.0: 初始版本，基本破解功能
- v2.0: 添加安全文件操作和详细日志
- v3.0: 添加调试模式和插件升级命令，不再备份原系统文件

## 免责声明

本脚本仅用于学习和研究目的。使用者应当遵守当地法律法规，不得将本脚本用于任何非法用途。作者不对使用本脚本造成的任何后果承担责任。

## 许可证

MIT License
