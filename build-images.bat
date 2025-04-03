@echo off

:: Set the build version
set BUILD_VERSION=1.0
echo Building Docker images with version %BUILD_VERSION%

:: Normal build with both tags (latest and normal)
docker build --build-arg VERSION=normal -t py-ds:%BUILD_VERSION%-normal -t py-ds:latest .

:: Small build
docker build --build-arg VERSION=small -t py-ds:%BUILD_VERSION%-small .

:: Large build
docker build --build-arg VERSION=large -t py-ds:%BUILD_VERSION%-large .

echo Build process completed!
pause