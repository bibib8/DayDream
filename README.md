# 🩵 Daydream Digital Diary - Flutter Mobile App

แอปพลิเคชันมือถือ Digital Diary & Scrapbook สไตล์ **Whimsical Y2K Coquette Editorial** รองรับทั้ง **iOS** และ **Android** สร้างด้วย **Flutter** เพื่อส่งอาจารย์และเตรียมความพร้อมขึ้น App Store & Google Play

---

## 📁 โครงสร้างโปรเจกต์ (Project Architecture)

```
flutter_app/
├── pubspec.yaml                 # Dependencies (google_fonts, provider, intl)
└── lib/
    ├── main.dart                # Main Entry Point & Bottom Navigation Shell
    ├── core/
    │   └── constants/
    │       ├── app_colors.dart      # Blue & White Y2K Tokens (#F8FCFF, #477FAF, #FEFEFE)
    │       └── app_typography.dart  # Google Fonts (Bodoni, Great Vibes, Cormorant, DM Sans, Caveat)
    ├── data/
    │   ├── models/
    │   │   ├── diary_model.dart     # Diary 3D Book Model
    │   │   ├── entry_model.dart     # Journal Entry & Stickers Model
    │   │   └── mood_model.dart      # 6 Realistic Emotions (Happy, Calm, Productive, Tired, Stressed, Down)
    │   └── sample_data.dart         # Mock Data สำหรับทดสอบและเดโม
    ├── providers/
    │   └── diary_provider.dart      # State Management (Provider)
    └── views/
        ├── landing/                 # 1. Landing Welcome Screen
        ├── auth/                    # 2. Login & Sign-up Screen
        ├── dashboard/               # 3. 3D Bookshelf & Daily Mood Bar
        ├── editor/                  # 4. #FEFEFE Notebook Editor with Graph/Lined/Dots Patterns
        └── mood/                    # 5. Emotional Archive & Monthly Mood Calendar
```

---

## 🚀 วิธีติดตั้ง Flutter และรันแอปบนเครื่อง Windows

### ขั้นตอนที่ 1: ดาวน์โหลด Flutter SDK
1. ไปที่เว็บไซต์ทางการ: [https://docs.flutter.dev/get-started/install/windows/mobile](https://docs.flutter.dev/get-started/install/windows/mobile)
2. ดาวน์โหลดไฟล์ `.zip` ของ Flutter (เช่น `flutter_windows_3.x.x-stable.zip`)
3. แตกไฟล์ไปไว้ที่ `C:\src\flutter` (หรือ `C:\flutter`)
4. เพิ่ม Path ใน System Environment Variables:
   * เพิ่ม `C:\src\flutter\bin` ลงในตัวแปร `Path`

### ขั้นตอนที่ 2: ติดตั้ง Dependencies
เปิด Command Prompt หรือ PowerShell ในโฟลเดอร์นี้:
```bash
flutter pub get
```

### ขั้นตอนที่ 3: รันแอปพลิเคชัน
* **รันบนเว็บเบราว์เซอร์ (ดูผลลัพธ์ทันทีโดยไม่ต้องต่อมือถือ):**
  ```bash
  flutter run -d chrome
  ```
* **รันบนโทรศัพท์ Android:**
  1. เสียบสาย USB เปิดโหมด **USB Debugging** (การแก้จุดบกพร่อง USB) บนมือถือ
  2. รันคำสั่ง:
     ```bash
     flutter run
     ```
* **Build ไฟล์ APK ส่งอาจารย์:**
  ```bash
  flutter build apk --release
  ```
  *(ไฟล์จะอยู่ที่ `build/app/outputs/flutter-apk/app-release.apk` สามารถส่งไฟล์นี้ให้อาจารย์ติดตั้งลงเครื่องได้ทันที)*
