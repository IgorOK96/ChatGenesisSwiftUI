Chat App

This SwiftUI-based chat application includes real-time messaging, user authentication. The app leverages Firebase services for backend storage and combines reactive programming with Combine.

Table of Contents

	1.	Project Structure
	2.	Features
	3.	Configuration
	4.	Dependencies
	5.	Getting Started
	6.	Troubleshooting

Project Structure

	•	Service
	•	ImagePicker: Utility to pick and handle image selection.
	•	NetworkMonitor: Monitors network connectivity status.
 
	•	ServiceFirebase
	•	AuthService: Manages user authentication with Firebase.
	•	FirestoreService: Handles data interactions with Firestore.
	•	StorageService: Manages file storage operations in Firebase.
 
	•	ModelChat
	•	MChat: Represents a chat session.
	•	MMessage: Represents a message in a chat.
	•	MUser: Represents a user in the app.
 
	•	View
	•	ChatListView, MessageView, RequestView: Various views for chat interaction and management.
 ![image](https://github.com/user-attachments/assets/828723a7-f272-40ad-86f5-645fc18220a7) ![image](https://github.com/user-attachments/assets/59e82061-fec5-4bd4-b23f-e811776b7d73) ![image](https://github.com/user-attachments/assets/ca4a6456-7e66-4b36-a454-7b11c0b42acf)

	•	PeopleList: Displays a list of available contacts.
  ![image](https://github.com/user-attachments/assets/d3075705-f0e1-4211-b6f1-83b59d99ada5) ![image](https://github.com/user-attachments/assets/5a23a243-822c-495f-86ff-525268719293)
 ![image](https://github.com/user-attachments/assets/db76d0e5-1e41-4a32-afa7-bf0d1e3d0bcf)
 
	•	WelcomeView, LoginView, SignView: Handles user onboarding and authentication.
 ![image](https://github.com/user-attachments/assets/d11fe08a-f81c-4d9d-a7a8-cfdb4a73ad7f) ![image](https://github.com/user-attachments/assets/87348ae2-98b2-47f0-b949-c38340debd28) ![image](https://github.com/user-attachments/assets/31a2190d-e996-4fe9-9f72-2cd9c0d94606) ![image](https://github.com/user-attachments/assets/161b0476-6b79-4020-905d-ace5d09f4485)
 
	•	NoConnectionView: Shown when there is no network connectivity.

Features

	•	Real-Time Chat: Users can send and receive text and image messages.
	•	User Authentication: Firebase-based email authentication.
	•	Media Sharing: Users can select and send images using ImagePicker.
	•	Offline Support: Basic offline support with NetworkMonitor for handling disconnections.
	•	Search and Filtering: Ability to search and filter users in real-time.

Configuration

Firebase Setup

	1.	Ensure you have configured Firebase with your project.
	2.	Update GoogleService-Info.plist in your Xcode project.
	3.	Enable Firestore, Authentication, and Storage services on Firebase.


Dependencies

	•	SwiftUI: For declarative UI design.
	•	Combine: Used for reactive programming to manage data streams and asynchronous operations.
	•	Firebase: For backend services, including authentication, Firestore, and storage.

Getting Started

	1.	Clone the Repository

[git clone ChatGenesisSwiftUI](https://github.com/IgorOK96/ChatGenesisSwiftUI.git)

	2.	Install Dependencies
	•	Make sure you have set up Firebase
	•	Install any required pods if using CocoaPods:

	3.	Run the Application
	•	Open ChatApp.xcworkspace in Xcode.
	•	Run the project on an iOS simulator or device.

Troubleshooting

	•	Network Issues: Check NetworkMonitor to confirm connectivity status.
	•	Image Loading Errors: Ensure images are stored and retrieved from Firebase Storage correctly.
	•	WebRTC Setup: Ensure correct configuration of ICE servers for stable peer-to-peer connections.
	•	Authentication Errors: Double-check Firebase authentication setup and permissions.

Let me know if you’d like any section expanded or if you need further customization based on specific project functionalities!
