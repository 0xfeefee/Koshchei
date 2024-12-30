@echo off

if exist "bin\\Koschei_Debug.exe" (
  pushd bin
    start cmd.exe /k "Koschei_Debug.exe"
  popd
) else (
  echo "Koschei_Debug [ERROR]: project not built ..."
)
