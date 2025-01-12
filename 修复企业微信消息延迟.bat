@echo off
chcp 65001 >nul


:: 启用延迟变量扩展
setlocal enabledelayedexpansion

:: 尝试从注册表读取 DataLocationPath
for /f "tokens=2*" %%i in ('reg query "HKCU\Software\Tencent\WXWork" /v DataLocationPath 2^>nul') do set wxworkPath=%%j

:: 如果注册表中没有 DataLocationPath，尝试从 User Shell Folders 获取文档路径
if not defined wxworkPath (
    echo 注册表中 DataLocationPath 不存在，尝试从 User Shell Folders 获取文档路径...
    
    for /f "tokens=2*" %%i in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v Personal') do set personalPath=%%j

    :: 输出 personalPath 的值，用于调试
    echo 获取的 Personal 路径为：!personalPath!

    :: 检查路径是否包含环境变量，并扩展
    if defined personalPath (
        :: 使用 call 扩展路径中的环境变量（例如 %USERPROFILE%）
        call set personalPath=!personalPath!
        echo 扩展后的路径为：!personalPath!
    ) else (
        echo 无法获取文档路径，请检查注册表设置！
        pause
        exit /b
    )
    
    :: 拼接文档路径和 WXWork 路径
    set wxworkPath=!personalPath!\WXWork
)

:: 输出最终路径，用于调试
echo 最终的 wxworkPath 为：!wxworkPath!

:: 检查路径是否为空
if "!wxworkPath!"=="" (
    echo 路径为空，请检查环境设置！
    pause
    exit /b
)

:: 检查路径是否存在
if not exist "!wxworkPath!" (
    echo 获取的路径无效，路径不存在：!wxworkPath!
    pause
    exit /b
)

:: 拼接 Global 文件夹路径
set globalPath=!wxworkPath!\Global

:: 输出成功获取到的路径信息
echo 成功获取到 Global 文件夹路径：!globalPath!

:: 检查 Config.cfg 文件是否存在
if exist "!globalPath!\Config.cfg" (
    echo 检测到 Config.cfg 文件，正在删除...
    del /q "!globalPath!\Config.cfg"
    echo 修复已完成，退出企业微信重新登录后即可生效。
) else (
    echo Config.cfg 文件不存在，修复失败！
)

:: 结束延迟扩展
endlocal

pause