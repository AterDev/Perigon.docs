# 生成内容
pwsh -NoProfile -File ./scripts/validate-docs.ps1
ezdoc build ./webinfo.json

