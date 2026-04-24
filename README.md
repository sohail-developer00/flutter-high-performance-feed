# 🚀 High-Performance Flutter Feed (Production-Grade)

This repository contains a highly optimized, production-ready social feed built with **Flutter**, **Riverpod**, and **Supabase**. It demonstrates senior-level expertise in performance profiling, memory management, and robust state synchronization.

---

## 🏗️ Architecture & State Management

The project follows **Clean Architecture** principles to ensure modularity and testability:

- **Service Layer**: [post_service.dart](lib/services/post_service.dart) handles raw Supabase RPC/REST calls and data transformation.
- **Provider Layer**: [post_provider.dart](lib/providers/post_provider.dart) manages the business logic, pagination state, and optimistic UI synchronization.
- **State Layer**: [post_state.dart](lib/providers/post_state.dart) defines an immutable state object for the feed.
- **UI Layer**: Optimized widgets with specialized performance boundaries.

### Key Decisions:
- **Riverpod `StateNotifier`**: Chosen for predictable state transitions and easy testing.
- **Optimistic UI with "In-Flight" Control**: Unlike standard toggles, our system tracks the *net change* during debouncing and ensures that sequential network requests for the same item do not overlap, preventing race conditions.

---

## ⚡ Performance Optimizations

### 1. GPU & Rasterization
- **`RepaintBoundary`**: Each post card is isolated in its own layer. This prevents the GPU from re-calculating the expensive `BoxShadow` (30 blur radius) during every scroll frame.
- **Dynamic `cacheExtent`**: Instead of a static value, we use `1.5x screen height`. This pre-renders enough items to prevent white flashes while avoiding excessive memory usage on low-end devices.

### 2. Memory & Image Decoding
- **Dynamic `memCacheWidth`**: We calculate the exact pixel width required based on the device's physical resolution (`width * devicePixelRatio`). This prevents OOM (Out of Memory) crashes by decoding large 4K source images at their exact display size.
- **Image Prefetching**: We use `precacheImage` to load the next batch of thumbnails as soon as the current batch is rendered, ensuring they are already in the GPU cache before the user scrolls to them.

### 3. Smooth UX
- **Hero Flight Shuttle**: Custom `flightShuttleBuilder` ensures a flicker-free transition during the Hero animation by using the already-loaded thumbnail as a placeholder.
- **Realistic Shimmer**: High-fidelity loading states with subtle shadows and depth to match the final UI.

---

## 🛡️ Edge Case & Error Handling

- **Spam Clicker**: Debouncing (500ms) + net-change logic ensures that clicking "Like" 20 times rapidly results in exactly **one or zero** API calls, while the UI remains instantly responsive.
- **Offline Revert**: If a network sync fails, the UI atomically reverts to the original state and notifies the user via a floating SnackBar.
- **Jank Detection**: Includes a `WidgetsBinding` timing callback that logs warnings to the console if a frame takes longer than 16ms to build (60fps threshold).

---

## 🛠️ Verification Guide (DevTools)

To verify the "Top 1%" implementation details, follow these steps:

### 1. GPU Performance (RepaintBoundary)
- Open **Flutter DevTools > Performance**.
- Check **"Highlight Repaint Boundaries"**.
- Scroll the feed. You will see that only the new items entering the screen are repainted; existing items remain static layers, saving massive GPU cycles on shadow math.

### 2. Memory Optimization (memCacheWidth)
- Open **DevTools > Memory**.
- Search for **"Image"** in the heap snapshot.
- Notice that the "decoded size" of images matches your device width (e.g., ~1080px for a 1080p screen), NOT the 4K raw source size.

### 3. Network Efficiency (Optimistic UI)
- Open **DevTools > Network**.
- Rapidly click a "Like" button 10 times.
- Observe that only a single `toggle_like` RPC request is dispatched after you stop clicking.

---

## 🚀 Getting Started

1. **Supabase Config**: Update `lib/core/supabase_config.dart` with your keys.
2. **Install Deps**: `flutter pub get`
3. **Run**: `flutter run --release` (Always profile in release mode!)

---
*Built with ❤️ by a Senior Flutter Engineer.*
