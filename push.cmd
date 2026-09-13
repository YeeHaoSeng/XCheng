@echo off
rem ============================================================
rem  一键上传（Windows 双击）：add + commit + rebase + push
rem  用法：双击运行 = 用默认消息提交；push.cmd "add post x" = 带消息
rem  无需手动设置代理：Clash(7897) 未开时提示超时，先开代理再重试
rem ============================================================
setlocal
set HTTPS_PROXY=http://127.0.0.1:7897
set HTTP_PROXY=http://127.0.0.1:7897

if "%*"=="" (
  set MSG=update: %date% %time%
) else (
  set MSG=%*
)

git add -A
git commit -m "%MSG%"
if errorlevel 1 goto :skip
git pull --rebase origin master
git push
:skip
echo.
echo ============ done. Actions 会自动重新部署约 1 分钟 ============
pause