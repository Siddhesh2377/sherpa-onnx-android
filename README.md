# Sherpa-ONNX for Android (JNI + Kotlin)

This project integrates the [sherpa-onnx](https://github.com/k2-fsa/sherpa-onnx) speech recognition toolkit into Android using JNI, Java, and Kotlin bindings. It provides an optimized on-device ASR (Automatic Speech Recognition) pipeline that can run locally without internet access.

---

## 🚀 Features

* ✅ On-device ASR using ONNX Runtime
* ✅ Built with `libsherpa-onnx-jni.so` for JNI compatibility
* ✅ Kotlin/Java wrapper for easy Android integration
* ✅ Supports TTS, speaker diarization, and VAD (if enabled)
* ✅ Works with static or shared ONNX Runtime

---

## 📁 Project Structure

| Folder                     | Description                                     |
| -------------------------- | ----------------------------------------------- |
| `csrc/`                    | Core C++ logic for ASR, TTS, diarization, etc.  |
| `c-api/`                   | C-style APIs for calling from C/Rust (optional) |
| `jni/`                     | JNI bindings to expose C++ to Java/Kotlin       |
| `java/`                    | Java wrapper classes for Android usage          |
| `kotlin/`                  | Kotlin-friendly interface and utilities         |
| `build-android-arm64-v8a/` | Output directory for Android .so builds         |

---

## 📦 Building for Android

### 🔧 Requirements

* Android NDK (tested with r22 and r27)
* CMake 3.13+
* Python 3 (only for setup tools, optional)
* Git, wget, unzip

### ⚙️ Build JNI Shared Library

Run the build script:

```bash
./build-android-arm64-v8a.sh
```

This builds:

* `libsherpa-onnx-jni.so`
* (Optionally) `libonnxruntime.so`

Copy the resulting `.so` files into your `app/src/main/jniLibs/arm64-v8a/` directory.

---

## 📱 Android Integration

1. Load native library:

```kotlin
System.loadLibrary("sherpa-onnx-jni")
```

2. Use SherpaOnnx from Kotlin:

```kotlin
val recognizer = SherpaOnnx(/* your config */)
recognizer.decode(audioBuffer)
```

3. (Optional) Configure ASR model path and other runtime settings.

---

## 🧪 Testing on Device

To test the native binary output:

```bash
adb push build-android-arm64-v8a/install/lib/*.so /data/local/tmp/
adb shell
cd /data/local/tmp
./sherpa-onnx --help
```

---

## 🧠 Notes

* If you enable GPU support (`SHERPA_ONNX_ENABLE_GPU=ON`), ensure you use compatible CUDA runtime.
* For Android, use static linking unless you're comfortable bundling all shared dependencies.
* If using RKNN (e.g., Rockchip NPU), enable with `SHERPA_ONNX_ENABLE_RKNN=ON` and provide runtime libs.

---

## 📚 Original Repo

This project is based on:

> [https://github.com/k2-fsa/sherpa-onnx](https://github.com/k2-fsa/sherpa-onnx)

All credits to the original authors for the C++ and ONNX-based speech models.

---

## 📄 License

Apache 2.0 - see [LICENSE](https://github.com/k2-fsa/sherpa-onnx/blob/master/LICENSE) for details.

---

## 👨‍💻 Author

Maintained and adapted for Android by **\[Siddhesh]**. If you build something cool with it, share it back with the community!
