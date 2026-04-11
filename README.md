# 🥚 Eggy: A Molecular Culinary Engine

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Architecture: Clean](https://img.shields.io/badge/Architecture-Clean-green?style=for-the-badge)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

Eggy is a sophisticated atmospheric-aware thermodynamic engine for molecular gastronomy. Built with **Flutter** and **Dart**, the application implements complex heat-transfer algorithms to predict the exact denaturation points of avian proteins. It is designed to demonstrate high-level engineering principles, including **SOLID** architecture, **Modular OOP**, and **Reactive State Management**.

---

## 🏗️ Software Engineering & Architecture

This project serves as a showcase for production-grade software engineering practices.

### **SOLID Principles in Practice**
- **Single Responsibility (SRP)**: Each module is strictly decoupled. For instance, the `EggPhysicsEngine` manages exclusively thermodynamic calculations, entirely abstracted from the UI or state.
- **Open-Closed (OCP)**: The system utilizes the `IEggRecipe` interface, allowing the easy addition of new culinary techniques (e.g., Soy Sauce Braising) without modifying the core calculation engine.
- **Liskov Substitution (LSP)**: All recipe implementations are interchangeable and adhere to consistent contracts, ensuring the `RecipeFactory` remains robust and stable.
- **Interface Segregation (ISP)**: UI components depend on specific, granular abstractions (e.g., `EggCalculator`, `MascotController`) rather than monolithic service classes.
- **Dependency Inversion (DIP)**: High-level features depend on abstractions. Implementation details are injected via **Provider** and **ProxyProvider**, ensuring a testable and maintainable dependency tree.

### **Modular OOP Design**
Eggy follows a **Feature-First** directory structure to ensure high cohesion and low coupling:
- `lib/core`: Immutable constants, foundational interfaces, and the core physics logic.
- `lib/features`: Domain-specific business logic divided by feature (Chat, Timer, Yolk-o-Meter, Preferences).
- `lib/shared/ui`: Reusable UI components and the thematic design system.
- `lib/screens`: Composition layer where state and UI converge.

---

## 🔬 Thermodynamic Modeling

The application's core logic is based on the **Charles Williams Formula** for calculating heat transfer and protein coagulation in avian eggs.

### **The Williams Formula**
The time ($t$) required to reach a specific target temperature ($T_{yolk}$) is calculated via:

$$t = \frac{M^{2/3} \cdot c \cdot \rho^{1/3}}{K \cdot \pi^2 \cdot (\frac{4\pi}{3})^{2/3}} \cdot \ln\left(0.76 \cdot \frac{T_{start} - T_{water}}{T_{yolk} - T_{water}}\right)$$

Where:
- **$M$**: Mass of the egg (grams).
- **$c$**: Specific heat capacity ($J \cdot g^{-1} \cdot K^{-1}$).
- **$\rho$**: Density ($g \cdot cm^{-3}$).
- **$K$**: Thermal conductivity ($W \cdot m^{-1} \cdot K^{-1}$).
- **$T_{water}$**: Ambient boiling point (calculated dynamically based on altitude/pressure).

### **Altitude Compensation**
The app dynamically calculates the boiling point ($T_{water}$) by adjusting for atmospheric pressure at the user's current altitude using the barometric formula, ensuring precision whether cooking at sea level or in high-altitude environments.

---

## 📚 Academic References & Research

The culinary and morphological data in Eggy is cited from peer-reviewed sources:

1. **Morphology & Scaling**: Data on avian egg ellipticity and scaling laws is based on *Church et al. (2019)*, "The shapes of 10,449 eggs," published in **Nature Scientific Data** ([doi:10.1038/s41597-019-0049-y](https://doi.org/10.1038/s41597-019-0049-y)).
2. **Food Safety Protocols**: Salmonella safety logic for soft-set eggs follows the **British Lion Standard** (UK Food Standards Agency, 2017).
3. **Heat Transfer**: Theoretical framework for the protein denaturation algorithms derived from **Charles D.H. Williams**, University of Exeter (Physics of Boiling an Egg).

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
