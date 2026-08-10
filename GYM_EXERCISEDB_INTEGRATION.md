# 🏋️ Gym & Fitness TV Display: ExerciseDB API Integration Proposal

Yes! **[ExerciseDB API](https://github.com/exercisedb/exercisedb-api)** is an **excellent fit** for the Gym TV display mode. It turns the TV screen into a high-value interactive workout assistant for gym members.

---

## 📸 Gym TV HUD Prototype (Powered by ExerciseDB)

![Gym TV Display Prototype with ExerciseDB Integration](file:///home/l3ul/HoursSignage/night_track_tv/gym_tv_exercisedb_prototype.jpg)

---

## 💡 How ExerciseDB Enhances the Gym TV Experience

### 1. 🏋️ Workout of the Day (WOD) & Live Exercise Tutorials
- **Dynamic Workouts**: The TV can automatically fetch and display daily workout routines (e.g. *Chest & Triceps Day*, *Leg Day Burner*).
- **Animated Demonstration GIFs**: ExerciseDB provides 1,300+ exercises with GIF demonstrations showing correct form, target muscles, and secondary muscles.

### 2. 🎯 Equipment Zone TV Screens
- If your gym has multiple TVs (e.g., Free Weight area, Cable Machine area, Cardio Zone), you can filter ExerciseDB by equipment:
  - `GET /exercises/equipment/dumbbell`
  - `GET /exercises/equipment/cable`
  - `GET /exercises/equipment/barbell`

### 3. 🗓️ Side-by-Side Class Schedules & Energy HUD
- **Left Side**: ExerciseDB Workout Spotlight (3D muscle highlight + execution steps + sets/reps).
- **Right Side**: Daily Gym Class Schedule (*10:30 AM CrossFit*, *11:45 AM HIIT Burn*, *1:00 PM Yoga*).

---

## 🛠️ Flutter Integration Plan for `GymIdleView`

Integrating ExerciseDB into [`GymIdleView`](file:///home/l3ul/HoursSignage/night_track_tv/lib/feature/tv_display/presentation/widget/views/gym_idle_view.dart):

```dart
// Fetch exercises by target muscle group (e.g., 'pectorals', 'quads')
Future<List<ExerciseModel>> fetchDailyWorkout(String targetMuscle) async {
  final response = await http.get(
    Uri.parse('https://exercisedb-api.vercel.app/api/v1/exercises/target/$targetMuscle'),
  );
  // Parse exercise name, target muscle, GIF URL, and instructions
}
```
