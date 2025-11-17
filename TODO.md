# CareHub Caregiver Dashboard UI Enhancements

## Home Tab 🏡
- [x] Welcome Header (Hero Card): Large Container with a subtle Linear Gradient. Contains the "CareHub" logo and a personalized message (e.g., "Welcome back, John!").
- [x] Next Shift Card (Top Priority): A highly visible, distinct card showing the next assigned shift. Includes client name, time, and a quick-access "Start Shift" button (using a vibrant accent color).
- [x] Notifications Card: A scrollable horizontal list of unread notifications (e.g., "New Shift Assigned," "Incident Report Submitted"). Use a small, pulsing AnimatedContainer for the notification badge count.
- [x] Weekly Shifts List: A vertical ListView of the week's shifts, each using an ExpansionTile or a simple card with a colored left-side border indicating shift status (Green = Completed, Blue = Upcoming, Yellow = Pending).

## Clients Tab 🧑‍🤝‍🧑
- [x] Search Bar: A prominent TextField at the top for quick client lookup.
- [x] Client List: A ListView.separated of ListTile or custom Client Cards. Each card features the client's profile picture/initials, name, and primary diagnosis.
- [x] Client Profile (On Tap): A dedicated screen with information displayed in structured, organized cards (e.g., one card for Diagnosis, one for Address/Map, and one for Emergency Contact). Use a subtle slide-in transition when opening the profile.

## Shifts Tab ⏱️
- [ ] Segmented Control/Tab Bar: A horizontal TabBar (or custom segmented control) for filtering: Pending | Upcoming | Completed.
- [ ] Pending Shifts: A list of cards with high visual impact. The Accept button uses the accent color, and the Reject button uses a clear outline, both with a small scale/fade animation on press.
- [ ] Active Shift (In Progress): A persistent, floating card or banner at the top showing the running timer/timestamp and a prominent End Shift button. This uses an AnimatedContainer to draw attention.
- [ ] Shift Notes: Use a simple TextFormField within the active or completed shift detail screen, with a clean "Save Notes" button that confirms with a brief SnackBar or a checkmark animation.

## Incident Reports Tab 🚨
- [ ] Form Structure: Use a multi-step or collapsible form to prevent overwhelming the user. Utilize ExpansionTile for sections (e.g., "Client Details," "Incident Details," "Actions Taken").
- [ ] Input Fields: Employ modern TextFormField with clear labeling and validation. Use dropdowns (DropdownButtonFormField) for standardized choices (e.g., Incident Type).
- [ ] Submission: A floating action button (FAB) or bottom-aligned submit button. On successful submission, use a Hero animation to transition the screen to a full-screen Confirmation Message with a celebratory Lottie animation or a simple checkmark icon.

## Profile Tab 👤
- [ ] Profile Header: A circular image widget with a subtle AnimatedCrossFade for the "Upload/Change Picture" button when tapped.
- [ ] Caregiver Info Cards: Use clear ListTile or custom cards for editable fields (e.g., Name, Phone, Email, ID). Use the suffixIcon of the ListTile to include a small edit icon that triggers the editing mode.
- [ ] Settings/Actions: Clearly defined sections for Logout, Change Password, etc., using simple, unstyled buttons or list items for easy access.

## Bottom Navigation
- [x] Custom Animated Bottom Nav: Implement smooth SlideTransition/FadeTransition between tabs.

## General
- [ ] Responsiveness: Ensure all widgets are responsive
- [ ] Performance: Use const constructors, minimize rebuilds
- [ ] State Management: Optimize with Provider/Riverpod
- [ ] Accessibility: WCAG AA compliant color contrast
