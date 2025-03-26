# 🤖 Android Emulator Setup on Ubuntu

This repository provides a complete guide to install and configure the **Android Emulator** on an Ubuntu system (with **hardware virtualization enabled**) for **APK testing and automation**.

---

## 📅 Repository URL
> [github.com/sariamubeen/emulator-setup-on-ubuntu](https://github.com/sariamubeen/emulator-setup-on-ubuntu)

---

## ✅ Requirements

- Ubuntu 20.04 or newer
- Minimum 4GB RAM (recommended 8GB+)
- Virtualization enabled in BIOS (Intel VT-x / AMD-V)
- Internet connection

---

## 🧰 Tools Installed

- OpenJDK 17
- Android Command-Line Tools (SDK)
- Android Emulator
- Platform Tools (`adb`, `fastboot`, etc.)
- Android System Image (API 30, x86_64)
- Optional: `scrcpy` for live screen mirroring of emulator/device

---

## 🚀 Quick Start: One Command Setup

Run this script to install everything and configure the emulator:

```bash
bash <(curl -s https://raw.githubusercontent.com/sariamubeen/emulator-setup-on-ubuntu/main/android_emulator_setup.sh)
```

> 🔐 **Note**: Always inspect scripts before running. Clone the repo if you prefer to execute locally.

---

## 📁 Installation & Configuration Steps

### 1. Install Dependencies

```bash
sudo apt update
sudo apt install -y openjdk-17-jdk unzip wget git libvirt-daemon-system qemu-kvm bridge-utils
```

### 2. Download Android Command-Line Tools

```bash
sudo mkdir -p /opt/android-sdk/cmdline-tools
sudo chown -R $USER:$USER /opt/android-sdk
cd /opt/android-sdk

wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O cmdline-tools.zip
unzip cmdline-tools.zip -d cmdline-tools
mv cmdline-tools/cmdline-tools cmdline-tools/latest
```

### 3. Set Environment Variables

```bash
export ANDROID_HOME=/opt/android-sdk
export PATH=$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin:$PATH
```

To make it permanent:

```bash
echo 'export ANDROID_HOME=/opt/android-sdk' >> ~/.bashrc
echo 'export PATH=\$ANDROID_HOME/emulator:\$ANDROID_HOME/platform-tools:\$ANDROID_HOME/cmdline-tools/latest/bin:\$PATH' >> ~/.bashrc
source ~/.bashrc
```

### 4. Install SDK Components

```bash
sdkmanager --sdk_root=$ANDROID_HOME --licenses

sdkmanager --sdk_root=$ANDROID_HOME \
  "platform-tools" \
  "emulator" \
  "platforms;android-30" \
  "system-images;android-30;google_apis;x86_64"
```

### 5. Create an Emulator (AVD)

```bash
echo "no" | avdmanager create avd -n test-x86 \
  -k "system-images;android-30;google_apis;x86_64" \
  --device "pixel" --force
```

### 6. Start the Emulator (Headless)

```bash
emulator -avd test-x86 -no-snapshot-save -no-window -no-audio -no-boot-anim &
```

### 7. Wait for Boot Completion

```bash
boot_completed=""
until [[ "$boot_completed" == "1" ]]; do
  sleep 5
  boot_completed=$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')
  echo "Waiting for emulator to boot..."
done

echo "✅ Emulator booted!"
```

---

## 📲 Installing Your APK

```bash
adb install /full/path/to/your_app.apk
```

Launch the app:

```bash
adb shell input keyevent 82  # unlock screen
adb shell am start -n your.package.name/.MainActivity
```

---

## 🧪 Live Screen Mirroring (Optional: `scrcpy`)

You can view and control the emulator/device screen from your Ubuntu desktop using `scrcpy`:

### Install `scrcpy`:

```bash
sudo apt install -y scrcpy
```

### Use it:

```bash
scrcpy
```

> Works with both physical devices and Android emulators.

---

## 🔧 Debugging Tips

| Problem | Fix |
|--------|-----|
| `adb: command not found` | Ensure `platform-tools` is installed and in `$PATH` |
| Emulator crashes | Check RAM/CPU limits, reduce image version |
| `KVM required for x86_64` | Enable virtualization in BIOS |
| APK install fails | Check APK is valid and signed, or use `adb install -r` |

---

## 📚 Want to Automate the Whole Setup?

Clone this repo and run the script:

```bash
git clone https://github.com/sariamubeen/emulator-setup-on-ubuntu.git
cd emulator-setup-on-ubuntu
chmod +x android_emulator_setup.sh
./android_emulator_setup.sh
```

---

## 🎩 Author

**[Saria Mubeen](https://github.com/sariamubeen)**

---

## 📄 License

MIT License — free to use and adapt.

