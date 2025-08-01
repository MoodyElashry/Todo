# 📝 Flutter TODO App

Welcome to the Flutter TODO App — your simple, elegant, and animated task manager! 🚀

---

## ✨ Features

- 🔐 **User Authentication**  
  Signup & login with slick slide animations and secure token storage.

- 📋 **Task Management**  
  Add, view, and locally mark tasks as completed with color-coded indicators.

- 🌗 **Dark & Light Mode**  
  Toggle between themes via a friendly switch — theme saved in SharedPreferences (restart app to apply). Default is Dark Mode! 🌙

- 👤 **User Profile**  
  Manage your profile and theme preference in one place.

- 🎨 **Smooth Animations**  
  Hero animations and slide transitions for a modern user experience.

---

## 🗂 Project Structure

- `main.dart`: App entry with theme loading from SharedPreferences  
- `auth.dart`: Handles signup, login, token management  
- `itemslistscreen.dart`: Displays TODO list with completion status  
- `signin.dart` & `signup.dart`: Auth screens with animations  
- `profile.dart`: Profile screen with dark/light mode toggle  
- `task_complete.dart`: Local storage for completed tasks  
- `item_model.dart` & `item_service.dart`: Models and backend API services  

---

## 🚀 Getting Started

1. Clone the repo:

```bash
git clone https://github.com/yourusername/flutter-todo-app.git
cd flutter-todo-app
```

2. Get dependencies:

```bash
flutter pub get
```

3. Run the app:

```bash
flutter run
```

---

## ⚠️ Notes

- Theme changes **require restarting the app** to take effect.  
- Default theme is **Dark Mode** on first launch.  
- Make sure hero tags are unique to avoid animation errors.

---

## 🐞 Known Issues

- Multiple widgets with the same Hero tag cause animation errors — keep tags unique!

---

## 💡 Future Improvements

- Live theme switching without restart  
- Upload profile and task images  
- Enhanced offline mode and error handling

---

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## ❤️ Made with love by Moody Elashry

Thanks for checking out my Flutter TODO app! Feel free to ⭐ the repo if you like it!

---

## 📬 Contact

If you want to contribute or report issues, please open an issue or pull request.

---

Happy coding! 👩‍💻👨‍💻
