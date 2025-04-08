@echo off

:: Set the build version
set BUILD_VERSION=1.0
set IMAGE_NAME=py-ds-dev
echo Building Docker images with version %BUILD_VERSION%

:: Normal build with both tags (latest and normal)
docker build --build-arg VERSION=normal -t %IMAGE_NAME%:%BUILD_VERSION%-normal -t %IMAGE_NAME%:latest .

:: Small build
docker build --build-arg VERSION=small -t %IMAGE_NAME%:%BUILD_VERSION%-small .

:: Large build
docker build --build-arg VERSION=large -t %IMAGE_NAME%:%BUILD_VERSION%-large .

echo Build process completed!
pause