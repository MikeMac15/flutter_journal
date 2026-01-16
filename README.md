Here is a professional `README.md` tailored for your GitHub portfolio. It highlights the technical complexity of the app while showcasing the specific features found in your code (Chapters, Ranked Lists, Question Walls, etc.).

---

# 📸 LifeLog: Photo Journal & Reflection App

**LifeLog** is a feature-rich personal journaling application built with **Flutter** and **Firebase**. It goes beyond simple text entries by integrating photo galleries, structured reflection prompts, and "Chapters" to organize life's major events.

Designed with a **Recruiter Demo Mode**, this project demonstrates advanced state management, cloud integration, and the ability to mock complex data layers for portfolio showcases.

---

## 📱 Features

### 📖 Core Journaling

* **Multimedia Entries**: Create entries with rich text, location data, activity tags (e.g., "Hiking," "Coding"), and photo galleries.
* **Timeline View**: View entries sorted chronologically or filtered by specific months.
* **Photo Management**: Efficient image uploading to Firebase Storage with hash-based deduplication logic.

### 🗂️ Organization & Hierarchy

* **Chapters**: Group related entries (e.g., "Summer Trip 2024", "Senior Year") into Chapters with custom cover images and descriptions.
* **Ranked Lists**: Create "Top 5" lists (e.g., "Top 5 Coffee Spots") and link them directly to related journal memories.
* **Year in Review (YIR)**: A structured section to recap the year with categories, items, and summaries.

### 💭 Reflection & Mindfulness

* **Question Walls**: Access a library of prompts across categories like *Daily Reflections*, *Nostalgia*, *Career*, and *Deep Cuts*.
* **Randomized Prompts**: The home screen serves a "Daily Mix" of reflection questions to inspire writing.
* **History**: Track and review past answers to see how your perspective changes over time.

### 🎨 Customization

* **Dynamic Theming**: Users can customize primary/secondary colors and background gradients.
* **Dark Mode**: Fully supported system-wide dark mode toggles.
* **Persisted Preferences**: Theme settings are saved to the user's Firestore profile.

---

## 🚀 Technical Highlights

### 🛠️ Architecture

* **State Management**: Built using `Provider` for scalable dependency injection and state handling across `UserProvider`, `DBProvider`, and `QuestionsProvider`.
* **Hybrid Data Layer**:
* **Production**: Uses **Cloud Firestore** for real-time data sync and **Firebase Auth** for Google Sign-In.
* **Demo Mode**: Implements a "Mock" architecture that swaps the Firestore service for a local, in-memory data store. This allows recruiters to test the full app experience immediately without authentication or network calls.



### ☁️ Backend (Firebase)

* **Auth**: Google Sign-In integration handling session restoration and user metadata.
* **Storage**: Image compression and upload handling for user avatars and journal photos.
* **Firestore**: Complex data modeling including nested collections for `answers`, `entries`, and `chapters`.

---

## ⚡ Demo Mode (Portfolio Feature)

This application includes a specialized **Recruiter Access** button on the login screen.

* **Zero Friction**: Bypasses Google Sign-In entirely.
* **Mock Data Injection**: Instantly populates the application state with a diverse set of hardcoded entries, chapters, and photos.
* **Safe**: Read-only access that ensures no personal database reads are triggered during the demo.

---

## 💻 Getting Started

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/photo-journal-app.git

```


2. **Install dependencies**
```bash
flutter pub get

```


3. **Firebase Setup**
* This project relies on `firebase_options.dart`. You will need to configure your own Firebase project and generate this file using the FlutterFire CLI if you wish to run the "Production" mode.
* *Note: You can run the app immediately in "Demo Mode" without Firebase configuration.*


4. **Run the app**
```bash
flutter run

```



---

## 🤝 Contributing

This is a personal portfolio project, but suggestions are welcome! Feel free to open an issue or submit a pull request.




# journal

                                            ~~ TO-DO ~~

~UI3~
[ ] Fix ########### INIT DB PROVIDER ############### on start up no call sometimes
[ ] Fix Yir message issues
[ ] Finish Home components
[ ] Unify the nav styles/colors






~UI2~

[ ?? ] Change order of photourls ability...?
[ ] Also need to figure out elligant favorites functionality

[-addonly7/23-] Add/Delete Photos when editing an old entry

[-7/23-] Fix Photo glitch ~ after 2nd photo it repeats same photo upload..?

[-7/23-] Fix Activities in journalEntry ~ seems to be a styling issue.. maybe infinity height?

[-5/21-] Grid view recents list

[-7/23-] Fix chapters

[-7/21-] I would like to explore options on coloring or other ideas for journal entries that do not have photos attached to them. I.E. what they show up as just before viewing like in the recents list

[-7/21-] Also add yearly questions

[-5/21-] Sort Entries (recent first) 