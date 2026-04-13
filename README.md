# 🥚 Eggy: The Professional Egg Research and Cooking Tool

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Architecture: Clean](https://img.shields.io/badge/Architecture-Clean-green?style=for-the-badge)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

Eggy is a precision-calibrated research tool and timer built for anyone who takes molecular egg science seriously. Built with **Flutter** and **Dart**, the app uses advanced heat-transfer physics to predict the exact cooking stage of an egg—from liquid-gold yolks to firm, jammy centers.

---

## ✨ Key Features

### **Smart AI Assistant**
Eggy features a context-aware AI assistant that remembers your conversation history to provide better, highly relevant advice:
- **Chef Mode**: Your practical kitchen companion. Focuses on techniques, recipes, and flavor profiles.
- **Professor Mode**: An updated **Egg & Avian Professor** persona for deep scientific inquiries about bird biology, nesting, and the molecular science of eggs.

### **Molecular Lab: Visual Heatmaps**
See exactly what is happening inside your egg in real-time.
- **Heat X-Ray**: Uses scientific data to visually track how the egg white and yolk are setting during the cook.
- **Stage Tracking**: Monitors transition stages (Liquid → Jammy → Firm) with high-fidelity visual feedback.

---

## 🎨 Design System: The Integrity Law

Eggy operates under a strict design system designed to minimize visual noise and maximize technical clarity. 

### **Color Palette (The 5-Color Law)**
Every visual element is derived from exactly five canonical tokens:

| Token | Hex | Usage |
| :--- | :--- | :--- |
| **Alabaster** | `#FBFBF8` | Primary background and laboratory surfaces. |
| **Vibrant Yolk** | `#FFCC33` | Brand accent, primary action buttons, and coagulation states. |
| **Onyx** | `#1A1A1A` | High-contrast typography and technical borders. |
| **White** | `#FFFFFF` | Layer foundations and card surfaces. |
| **Slate** | `#334756` | Technical secondary color for inactive states and metadata. |

### **Typography (High-Fidelity Duo)**
To maintain scientific readability, the app uses a strict two-font system:
- **Instrument Serif (Editorial Serif)**: Used for high-level branding, identity, and primary headers.
- **Inter (Precision Sans)**: Used for all technical data, body instructions, and molecular metadata.

---

## 🏗️ UI & UX Standards

### **Vintage Classic Mechanical Egg Timer**
Traditional egg timers are tactile and mechanical. Eggy honors this heritage with a realistic interface inspired by **vintage classic mechanical egg timers**:
- **Tactile Logic**: Features a physical "wind-up" ritual to set the time, mirroring the tactile feel of vintage hardware.
- **Real-World Physics**: The countdown follows a strict clockwise ritual, ensuring the visual experience feels like a real mechanical device.

---

## 🏗️ Software Engineering & Technical Standards

This project serves as a showcase for production-grade software engineering and Clean Architecture.

### **Clean Architecture & SOLID**
- **Single Responsibility (SRP)**: Each module is strictly decoupled. For instance, the physics engine handles math independently of the user interface.
- **Dependency Inversion (DIP)**: Features depend on stable abstractions, ensuring the app is maintainable, testable, and robust.
- **Feature-First Structure**: The project is organized by domain (Chat, Timer, Physics) to ensure high clarity and low code complexity.

### **Scientific Accuracy**

#### **The Williams Formula**
Eggy implements the **Williams Formula**, a rigorous heat-transfer model for predicting egg doneness. This model accounts for the internal thermal kinetics of an egg's multi-layered structure:

$$t = \frac{M^{2/3} \cdot c \cdot \rho^{1/3}}{K \cdot \pi^2 \cdot (\frac{4\pi}{3})^{2/3}} \cdot \ln\left(0.76 \cdot \frac{T_{initial} - T_{water}}{T_{yolk} - T_{water}}\right)$$

Where:
- **$M$**: Egg mass (species and size-adjusted).
- **$c$ and $\rho$**: Species-specific heat capacity and density.
- **$K$**: Thermal conductivity (adjusted for shell thickness and species).
- **$T_{water}$**: The boiling water temperature.
- **$T_{initial}$**: Initial internal temperature (Fridge 4°C or Room 21°C).
- **$T_{yolk}$**: The targeted molecular coagulation temperature.

#### **Zero-Noise Physics (Altitude)**
Eggy employs a **Zero-Noise Physics** policy. Unlike traditional tools that attempt unreliable GPS-based altitude compensation, Eggy uses a standardized **100.0°C laboratory baseline** for boiling water. This ensures:
- **Consistency**: Eliminates environmental variance for maximum repeatability.
- **Scientific Truth**: In high-fidelity molecular cooking, a fixed boiling point is the gold standard for laboratory-grade precision.

#### **Peer-Reviewed Data**
Biological and morphological data—including thermal conductivity and specific heat of various avian eggs—is cited from research published in **Nature Scientific Data** and other academic journals.

---

## 🛠️ Tech Stack
- **Framework**: Flutter (Stable)
- **Language**: Dart (Sound Null Safety)
- **State Management**: Provider / ChangeNotifier
- **Intelligence**: Llama 3.3-70B via OpenRouter (Multi-contextual AI logic)
- **Persistence**: Shared Preferences

---

## 👨‍🍳 Developer
Crafted with an uncompromising focus on engineering standards and culinary science by **gwaisey**.
**Contact**: [gracemaegozali@gmail.com](mailto:gracemaegozali@gmail.com)
