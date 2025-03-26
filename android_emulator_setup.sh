#!/bin/bash

set -e

echo "🔧 Starting Android Emulator Setup on Ubuntu..."
sleep 1

# ---- CONFIG ---- #
ANDROID_SDK_ROOT="/opt/android-sdk"
AVD_NAME="test-x86"
API_LEVEL="30"
SYSTEM_IMAGE="system-images;android-${API_LEVEL};google_apis;x86_64"
DEVICE="pixel"
# ---------------- #

echo "📦 Installing required packages..."
sudo apt update
sudo apt install -y openjdk-17-jdk wget unzip git qemu-kvm libvirt-daemon-system bridge-utils curl

echo "📁 Creating Android SDK directories at $ANDROID_SDK_ROOT..."
sudo mkdir -p $ANDROID_SDK_ROOT/cmdline-tools
sudo chown -R $USER:$USER $ANDROID_SDK_ROOT
cd $ANDROID_SDK_ROOT

if [ ! -f "cmdline-tools.zip" ]; then
  echo "⬇️ Downloading Android command-line tools..."
  wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O cmdline-tools.zip
fi

echo "📦 Unzipping tools..."
unzip -qo cmdline-tools.zip -d cmdline-tools
mv cmdline-tools/cmdline-tools cmdline-tools/latest

echo "🔧 Setting up environment variables..."
export ANDROID_HOME=$ANDROID_SDK_ROOT
export PATH=$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$ANDROID_HOME/cmdline-tools/latest/bin:$PATH

# Add to ~/.bashrc if not already present
if ! grep -q "ANDROID_HOME" ~/.bashrc; then
  echo "📌 Persisting environment variables to ~/.bashrc"
  echo -e "\n# Android SDK setup" >> ~/.bashrc
  echo "export ANDROID_HOME=$ANDROID_SDK_ROOT" >> ~/.bashrc
  echo "export PATH=\$ANDROID_HOME/platform-tools:\$ANDROID_HOME/emulator:\$ANDROID_HOME/cmdline-tools/latest/bin:\$PATH" >> ~/.bashrc
fi

echo "🔑 Accepting SDK licenses..."
yes | sdkmanager --sdk_root=$ANDROID_HOME --licenses

echo "📥 Installing SDK components..."
sdkmanager --sdk_root=$ANDROID_HOME \
  "platform-tools" \
  "emulator" \
  "platforms;android-${API_LEVEL}" \
  "$SYSTEM_IMAGE"

echo "🛠️ Creating AVD: $AVD_NAME..."
echo "no" | avdmanager create avd -n "$AVD_NAME" \
  -k "$SYSTEM_IMAGE" \
  --device "$DEVICE" --force

echo "🚀 Launching emulator in headless mode..."
nohup emulator -avd "$AVD_NAME" -no-window -no-audio -no-boot-anim > /dev/null 2>&1 &

echo "⏳ Waiting for emulator to boot..."
boot_completed=""
until [[ "$boot_completed" == "1" ]]; do
  sleep 5
  boot_completed=$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')
  echo "Waiting..."
done

echo "✅ Emulator is up and running!"

echo "🎯 You can now install your APK with:"
echo "   adb install /path/to/your_app.apk"
echo "   adb shell am start -n your.package.name/.MainActivity"
echo ""
echo "🖥️ To mirror the emulator screen (optional):"
echo "   sudo apt install scrcpy && scrcpy"

echo "🎉 Done! Android emulator is ready for testing."
