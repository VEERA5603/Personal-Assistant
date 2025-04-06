
# Personal Assistant

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Flask](https://img.shields.io/badge/Flask-000000?style=for-the-badge&logo=flask&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

This project is a system control application that allows users to control a system by entering the IP address of the system from a Flutter app and sending commands. The mobile device and the laptop should be on the same network. The Python backend runs on the laptop or you can control via web app.

## Table of Contents
- [Description](#description)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Technologies Used](#technologies-used)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

## Description

The Personal Assistant project enables users to control a system by sending commands from a Flutter app to a Python backend running on a laptop. The mobile device and the laptop must be on the same network for this to work or it can controlled via web also.

## Features

- Control a system using a Flutter app.
- Enter the IP address of the system to connect.
- Send commands to the system from the mobile app.
- Flask backend to process and execute commands on the laptop.
- Commands include:
  - Opening and closing applications.
  - Taking screenshots.
  - Playing YouTube videos.
  - Shutting down or restarting the computer.
  - Checking internet connectivity.
  - Retrieving IP addresses and system information.
  - Controlling volume.
  - Setting reminders.
  - Telling jokes.
  - Taking photos.
  - Running programs.
  - Finding files.
  - Searching on Google.

## Installation

### Prerequisites

- Flutter SDK
- Python 3.x
- Mobile device and laptop on the same network

### Steps

1. Clone the repository:

    
    git clone https://github.com/VEERA5603/Personal-Assistant.git
 

2. Navigate to the Flutter app directory and install dependencies:

   
    cd Personal-Assistant
    flutter pub get


3. Navigate to the Python backend directory and install dependencies:

 
    cd Backend
    pip install -r requirements.txt
  

## Usage

1. Start the Python backend on the laptop:

  
    python Backend/app.py
 

2. Run the Flutter app:

   
    flutter run
   

3. Enter the IP address of the system in the Flutter app or you can also use it in web.

4. Use the app to send commands to the system.

## Technologies Used

- **Dart**: Used for building the Flutter app.
- **Python**: Used for the backend flask to process and execute commands.
- **HTML, CSS, JavaScript**: Other technologies used in the project.


## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

