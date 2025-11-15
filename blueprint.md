# CareHub Blueprint

## Overview

CareHub is a mobile application designed to connect caregivers and parents, providing a centralized platform for communication, scheduling, and sharing information about child care.

## Style, Design, and Features

### Implemented Features

*   **User Authentication**: Full authentication flow including Login, Registration, and Forgot Password screens. The system uses Firebase Authentication.

*   **Role-Based Access Control**: The application distinguishes between two user roles: `parent` and `caregiver`.
    *   **Role-Based Navigation**: The splash screen checks the authenticated user's role from Firestore and navigates them to the appropriate dashboard (`ParentDashboard` or `CaregiverDashboard`).

*   **Parent Dashboard**: A comprehensive dashboard for parents with two main sections accessible via a `BottomNavigationBar`:
    *   **Available Caregivers**: Displays a real-time list of all available caregivers from Firestore. Parents can view caregiver profiles and initiate the booking process.
    *   **My Bookings**: Shows a list of all bookings made by the logged-in parent.

*   **Caregiver Dashboard**: A dedicated dashboard for caregivers that displays a real-time list of their upcoming appointments. It fetches bookings specifically assigned to the logged-in caregiver.

*   **Caregiver Management (Admin-like functionality for Parents)**:
    *   Full CRUD (Create, Read, Update, Delete) operations for caregiver profiles, including name, qualifications, and profile pictures.
    *   Profile pictures are uploaded and managed using Firebase Storage.

*   **Scheduling and Booking System**:
    *   Parents can book caregivers from the caregiver details page.
    *   A user-friendly booking page with a calendar (`table_calendar`) allows parents to select a date and time for the appointment.
    *   All booking information is stored in Firestore and is displayed in the respective dashboards for both parents and caregivers.

*   **Modern UI/UX and Theming**:
    *   **Material 3 Design**: The application is built using the latest Material 3 design principles.
    *   **Light & Dark Themes**: Includes both light and dark themes that can be set to follow the system's theme settings, providing a comfortable viewing experience in any lighting condition.
    *   **Custom Typography**: Uses the `Poppins` font from `google_fonts` for a clean and modern aesthetic.
    *   **Consistent Branding**: A cohesive design is maintained across the app with a consistent color scheme, logo, and component styling.

*   **State Management and Navigation**:
    *   The `get` package is used for state management and provides a simple and powerful routing solution.

*   **Backend and Services**:
    *   **Firebase Suite**: Leverages Firebase for Authentication, Firestore Database, and Cloud Storage.
    *   **Service-Oriented Architecture**: The logic is separated into services (`AuthService`, `DatabaseService`, `StorageService`, `BookingService`) to ensure a clean and maintainable codebase.

## Final Implementation Summary

The project is now complete. All core features have been implemented, providing a fully functional MVP (Minimum Viable Product) for the CareHub application. The app successfully connects parents and caregivers, allows for scheduling and management of bookings, and provides a role-based experience for each user type. The codebase is well-structured with a service-oriented architecture, and the UI is modern, responsive, and includes both light and dark themes.
