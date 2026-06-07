@echo off
echo Generating Release Keystore for RoadRobos...
echo Please remember the password you enter here!
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

echo.
echo ========================================================
echo Keystore generated at: upload-keystore.jks
echo Next Steps:
echo 1. Open 'android/key.properties' (create it if it doesn't exist)
echo 2. Add the following lines:
echo storePassword=YOUR_PASSWORD_HERE
echo keyPassword=YOUR_PASSWORD_HERE
echo keyAlias=upload
echo storeFile=upload-keystore.jks
echo ========================================================
pause
