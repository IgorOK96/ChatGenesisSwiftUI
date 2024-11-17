Chat App

Chat App — это современное приложение для обмена сообщениями, созданное на основе SwiftUI.
Оно поддерживает реальное время, загрузку изображений, управление пользователями и обеспечивает надежное взаимодействие благодаря интеграции с Firebase.

Содержание

	1.	Описание проекта
	2.	Функциональность
	3.	Структура проекта
	4.	Настройка и конфигурация
	5.	Зависимости
	6.	Использование
	7.	Особенности реализации
	8.	Трудности и решения

Описание проекта

Chat App — это приложение, позволяющее пользователям:

	•	Обмениваться текстовыми и мультимедийными сообщениями.
	•	Управлять своими чатами.
	•	Искать и добавлять пользователей.
	•	Загрузить и просматривать изображения, используя кэширование.

Проект разработан с применением архитектурных принципов MVVM и реактивного программирования с помощью Combine.

Функциональность

	•	Аутентификация:
	•	Регистрация и вход через email.
	•	Поддержка Firebase Authentication.
 
	•	Чаты:
	•	Реальные чаты с поддержкой сообщений в реальном времени.
	•	Отправка изображений и текста.
	•	Разделение на активные чаты и ожидающие.
 
	•	Пользователи:
	•	Поиск пользователей.
	•	Добавление в друзья.
	•	Поддержка отображения профиля.
 
	•	Изображения:
	•	Загрузка изображений через Alamofire.
	•	Кэширование с помощью NSCache.
	•	Поиск и фильтрация:
	•	Реализована система поиска по чатам и пользователям.

Структура проекта

├── Service
│   ├── ImageService.swift         // Кэширование и загрузка изображений
│   ├── NetworkMonitor.swift       // Проверка сети
├── ServiceFirebase
│   ├── AuthService.swift          // Управление аутентификацией
│   ├── FirestoreService.swift     // Взаимодействие с Firestore
│   ├── StorageService.swift       // Загрузка файлов в Firebase Storage
├── ModelChat
│   ├── MChat.swift                // Модель чата
│   ├── MMessage.swift             // Модель сообщения
│   ├── MUser.swift                // Модель пользователя
├── View
│   ├── ChatListView               // Список чатов
│   │   ├── ActiveChatsListView.swift
│   │   ├── ChatListViewModel.swift
│   ├── MessageView                // Окно сообщений
│   │   ├── ChatView.swift
│   │   ├── ChatViewModel.swift
│   ├── PeopleSearch               // Поиск пользователей
│   │   ├── PeopleListView.swift
│   │   ├── PeopleListViewModel.swift
│   ├── WelcomeView                // Аутентификация
│       ├── LoginView.swift
│       ├── SignUpView.swift
│       ├── NoConnectionView.swift

Настройка и конфигурация

	1.	Firebase:
	•	Добавьте файл GoogleService-Info.plist в проект.
	•	Настройте Firebase Authentication, Firestore и Storage.
 
	2.	Dependencies:
	•	Установите зависимости через Swift Package Manager:
	•	Firebase (Auth, Firestore, Storage)
	•	Alamofire (для загрузки изображений).
 
	3.	Запуск:
	•	Склонируйте проект.
	•	Настройте Firebase консоль.
	•	Запустите проект через Xcode.

Зависимости

	•	SwiftUI — построение интерфейса.
	•	Combine — управление потоками данных.
	•	Firebase:
	•	Auth для аутентификации.
	•	Firestore для управления данными.
	•	Storage для загрузки файлов.
	•	Alamofire — загрузка изображений.

Использование

1. Аутентификация

![image](https://github.com/user-attachments/assets/78e8947b-54ec-4fb9-aa4a-4c157729129b)
![image](https://github.com/user-attachments/assets/63e8f0b9-fa8f-4d26-bba8-8aec938cae53)
![image](https://github.com/user-attachments/assets/b0409e2c-0a00-4010-afa1-7626514d4c53)


2. Чаты
![image](https://github.com/user-attachments/assets/94406b87-a8d0-419e-b06c-7eec8d9b9062)
![image](https://github.com/user-attachments/assets/f965bd1c-8131-40e7-a321-91d25be9c7fb)
![image](https://github.com/user-attachments/assets/871751a8-4b25-41f8-a7d5-7726d242ce01)



4. Поиск пользователей
![image](https://github.com/user-attachments/assets/42d2ff5e-b154-4d79-8785-233465e6688c)
![image](https://github.com/user-attachments/assets/bb7b941b-cf20-4ab2-8f8a-a8af5e580c23)
![image](https://github.com/user-attachments/assets/8173b1d6-1c98-451c-87bb-bae7d7344d92)

Особенности реализации

	1.	ImageService:
	•	Реализовано кэширование изображений с использованием NSCache.
	•	Загрузка изображений через Alamofire.
	2.	FirestoreService:
	•	Потоки для наблюдения за изменениями в пользователях, чатах и сообщениях.
	•	Использование Combine для реактивного управления данными.
	3.	MVVM Архитектура:
	•	Все бизнес-логика вынесена в ViewModel, что упрощает поддержку и тестирование.

Трудности и решения

1. Проблемы с производительностью при загрузке изображений

	•	Реализовано кэширование изображений в NSCache.

2. Устаревшие данные при изменениях в Firestore

	•	Используются Publisher’ы с addSnapshotListener для автоматического обновления данных.

3. Управление состоянием сети

	•	Используется NetworkMonitor для отслеживания подключения к сети.

Скриншоты интерфейса

Добавьте сюда несколько скриншотов с основными экранами вашего приложения.

Если есть что-то, что стоит уточнить или дополнить, дай знать!

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
	•	Authentication Errors: Double-check Firebase authentication setup and permissions.
