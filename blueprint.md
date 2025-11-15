# CareHub Blueprint

## Overview

CareHub is a mobile application designed to connect caregivers and parents, providing a centralized platform for communication, scheduling, and sharing information about child care.

## Style, Design, and Features

### Initial Version

*   **Color Palette**: The application uses a modern and fresh color scheme with light green as the primary accent color and a clean white background. This combination creates a calming and inviting user experience.
*   **Typography**: The app uses the `Poppins` font from `google_fonts` for a clean and professional look.
*   **Logo**: A simple and memorable logo featuring a heart icon represents the CareHub brand.

### Implemented Features

*   **User Authentication**: Basic screens for Login, Registration, and Forgot Password.
*   **Enhanced Parent Dashboard**: The `ParentDashboard` has been redesigned to provide a more intuitive and efficient user experience. It now directly displays a real-time list of available caregivers, eliminating the need for a separate management page. A floating action button allows for easy addition of new caregivers.
*   **Enhanced Caregiver Dashboard**: The `CaregiverDashboard` now displays a real-time list of upcoming appointments for the logged-in caregiver. It uses a `StreamBuilder` to listen for new bookings and updates the UI automatically. If no appointments are scheduled, it shows a user-friendly message.
*   **Navigation**: The app uses the `get` package for easy and efficient navigation.
*   **Theme and Branding**: The app has a consistent theme with a light green and white color scheme, custom Poppins font, and the CareHub logo on the splash screen.
*   **Caregiver Management (Admin)**:
    *   **Firebase Integration**: The app is connected to Firebase for backend services.
    *   **Firestore Database**: A `DatabaseService` manages all interactions with Firestore for storing and retrieving caregiver data.
    *   **Firebase Storage**: A `StorageService` handles the upload and deletion of caregiver profile pictures.
    *   **CRUD Functionality**: Full CRUD (Create, Read, Update, Delete) operations for caregiver management are now integrated directly into the `ParentDashboard` and `AddEditCaregiverPage`.
*   **Caregiver Details Screen**:
    *   A dedicated page to display the full details of a selected caregiver.
    *   Navigation to the booking page is enabled from this screen.
*   **Scheduling and Booking**:
    *   **Booking Model**: A `Booking` model defines the structure for appointments.
    *   **Booking Service**: A `BookingService` manages all booking-related interactions with Firestore, including adding new bookings and retrieving bookings for a specific caregiver.
    *   **Booking Page**: A dedicated page allows parents to select a date and time to book a caregiver. The `table_calendar` package is used to provide an intuitive calendar interface.

## Current Plan

*   **User Roles and Permissions**: Implement a system to differentiate between parent and administrator roles, restricting access to administrative features.
*   **Final Touches & Bug Fixes**: I will add some final design touches and fix any bugs found.
