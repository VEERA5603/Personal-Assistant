from flask import Flask, request, jsonify, render_template
from flask_cors import CORS
import webbrowser
import os
import pyautogui
import pywhatkit
import datetime
import requests
import socket
import platform
import psutil
import pyttsx3
import random
import cv2
import subprocess
import tkinter as tk
from tkinter import filedialog

app = Flask(__name__)
CORS(app)  # Enable CORS to allow Flutter requests

engine = pyttsx3.init()

def speak(text):
    """Convert text to speech."""
    engine.say(text)
    engine.runAndWait()

def get_local_ip():
    """Retrieve the local IP address of the machine."""
    try:
        hostname = socket.gethostname()
        local_ip = socket.gethostbyname(hostname)
        return local_ip
    except:
        return "Unable to retrieve IP"

def get_public_ip():
    """Fetch public IP using an external API."""
    try:
        ip = requests.get("https://api64.ipify.org?format=json").json()["ip"]
        return ip
    except:
        return "Unable to fetch public IP"

def take_photo():
    """Take a photo using the camera and save it."""
    try:
        # Initialize the camera
        camera = cv2.VideoCapture(0)
        
        # Check if camera opened successfully
        if not camera.isOpened():
            return "Error: Could not open camera"
        
        # Capture a frame
        ret, frame = camera.read()
        
        if not ret:
            return "Error: Could not capture image"
        
        # Save the image
        timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        file_path = f"photo_{timestamp}.jpg"
        cv2.imwrite(file_path, frame)
        
        # Release the camera
        camera.release()
        
        return f"Photo taken and saved as {file_path}"
    except Exception as e:
        return f"Error taking photo: {str(e)}"

import os
import subprocess

def run_program(program_name):
    """Run a program by name."""
    try:
        # Expanded programs dictionary with more applications and accurate commands
        programs = {
            # Office Applications
            "word": ["start", "winword"],
            "excel": ["start", "excel"],
            "powerpoint": ["start", "powerpnt"],
            "outlook": ["start", "outlook"],
            "onenote": ["start", "onenote"],
            "access": ["start", "msaccess"],
            "publisher": ["start", "mspub"],
            
            # System Utilities
            "paint": ["start", "mspaint"],
            "notepad": ["notepad"],
            "calculator": ["calc"],
            "cmd": ["start", "cmd"],
            "terminal": ["start", "cmd"],
            "powershell": ["start", "powershell"],
            "explorer": ["explorer"],
            "task manager": ["taskmgr"],
            "control panel": ["control"],
            "settings": ["start", "ms-settings:"],
            "snipping tool": ["start", "snippingtool"],
            
            # Browsers
            "firefox": ["start", "firefox"],
            "edge": ["start", "msedge"],
            "chrome": ["start", "chrome"],
            "opera": ["start", "opera"],
            "brave": ["start", "brave"],
            "safari": ["start", "safari"],
            
            # Media & Entertainment
            "vlc": ["start", "vlc"],
            "spotify": ["start", "spotify"],
            "netflix": ["start", "netflix:"],
            "itunes": ["start", "itunes"],
            "windows media player": ["start", "wmplayer"],
            "photos": ["start", "ms-photos:"],
            
            # Communication & Collaboration
            "discord": ["start", "discord"],
            "zoom": ["start", "zoom"],
            "teams": ["start", "teams"],
            "skype": ["start", "skype"],
            "slack": ["start", "slack"],
            "telegram": ["start", "telegram"],
            "whatsapp": ["start", "whatsapp"],
            
            # Development Tools
            "code": ["start", "code"],
            "vscode": ["start", "code"],
            "visual studio code": ["start", "code"],
            "visual studio": ["start", "devenv"],
            "intellij": ["start", "idea64"],
            "pycharm": ["start", "pycharm64"],
            "eclipse": ["start", "eclipse"],
            "git bash": ["start", "git-bash"],
            "anaconda": ["start", "anaconda-navigator"],
            "jupyter": ["start", "jupyter-notebook"],
            
            # Graphics & Design
            "photoshop": ["start", "photoshop"],
            "illustrator": ["start", "illustrator"],
            "gimp": ["start", "gimp"],
            "blender": ["start", "blender"],
            "figma": ["start", "figma"],
            
            # Other Popular Apps
            "steam": ["start", "steam"],
            "epic games": ["start", "epicgameslauncher"],
            "obs": ["start", "obs64"],
            "audacity": ["start", "audacity"],
            "winrar": ["start", "winrar"],
            "7zip": ["start", "7zfm"],
            "adobe reader": ["start", "acrord32"]
        }
        
        # Try to find the program in our dictionary
        if program_name.lower() in programs:
            command = programs[program_name.lower()]
            if isinstance(command, list):
                subprocess.Popen(command, shell=True)
            else:
                subprocess.Popen(command, shell=True)
            return f"Running {program_name}"
        else:
            # Try to run it using the start command
            subprocess.Popen(["start", program_name], shell=True)
            return f"Attempting to run {program_name}"
    except Exception as e:
        return f"Error running program: {str(e)}"
        
def find_file(file_pattern):
    """Find a file using a GUI file dialog."""
    try:
        # Create a hidden root window
        root = tk.Tk()
        root.withdraw()
        
        # Open the file dialog
        file_path = filedialog.askopenfilename(
            title=f"Find file matching: {file_pattern}",
            filetypes=[("All files", "*.*")]
        )
        
        # Check if a file was selected
        if file_path:
            # Open the selected file's directory
            directory = os.path.dirname(file_path)
            os.startfile(directory)
            return f"Found file: {file_path}"
        else:
            return "No file selected"
    except Exception as e:
        return f"Error finding file: {str(e)}"

def search_google(query):
    """Search Google for a specific query."""
    try:
        # Format the query for a URL
        search_query = query.replace(" ", "+")
        # Open the default web browser with the Google search
        webbrowser.open(f"https://www.google.com/search?q={search_query}")
        return f"Searching Google for: {query}"
    except Exception as e:
        return f"Error searching Google: {str(e)}"

def execute_command(command):
    """Process commands and return appropriate responses."""

    if "open browser" in command:
        webbrowser.open("https://www.google.com")
        return "Opening browser"

    elif "close browser" in command:
        pyautogui.hotkey('alt', 'f4')
        return "Closing browser"

    elif "play" in command:
        song = command.replace("play", "").strip()
        pywhatkit.playonyt(song)
        return f"Playing {song} on YouTube"

    elif "shutdown" in command:
        os.system("shutdown /s /t 5")
        return "Shutting down your computer"

    elif "restart" in command:
        os.system("shutdown /r /t 5")
        return "Restarting your computer"

    elif "screenshot" in command:
        screenshot = pyautogui.screenshot()
        screenshot.save("screenshot.png")
        return "Screenshot taken and saved"

    elif "time" in command:
        now = datetime.datetime.now().strftime("%H:%M:%S")
        return f"The current time is {now}"

    elif "volume up" in command:
        pyautogui.press("volumeup")
        return "Increasing volume"

    elif "volume down" in command:
        pyautogui.press("volumedown")
        return "Decreasing volume"

    elif "mute" in command:
        pyautogui.press("volumemute")
        return "Muting volume"

    elif "open notepad" in command:
        os.system("notepad")
        return "Opening Notepad"

    elif "open calculator" in command:
        os.system("calc")
        return "Opening Calculator"

    elif "open chrome" in command:
        os.system("start chrome")
        return "Opening Google Chrome"

    elif "open file explorer" in command:
        os.system("explorer")
        return "Opening File Explorer"

    elif "lock" in command:
        os.system("rundll32.exe user32.dll,LockWorkStation")
        return "Locking computer"

    elif "check internet" in command:
        try:
            socket.create_connection(("www.google.com", 80))
            return "Internet is connected"
        except OSError:
            return "No internet connection detected"

    elif "get ip address" in command:
        return f"Public IP: {get_public_ip()}, Local IP: {get_local_ip()}"

    elif "system info" in command:
        sys_info = platform.uname()
        return f"System: {sys_info.system}, Node: {sys_info.node}, Release: {sys_info.release}, Version: {sys_info.version}, Machine: {sys_info.machine}, Processor: {sys_info.processor}"

    elif "battery status" in command:
        battery = psutil.sensors_battery()
        return f"Battery percentage is {battery.percent}%" if battery else "Battery status unavailable"

    elif "set reminder" in command:
        with open("reminders.txt", "a") as file:
            file.write(command.replace("set reminder", "").strip() + "\n")
        return "Reminder added"

    elif "tell a joke" in command:
        jokes = [
            "Why don't skeletons fight each other? Because they don't have the guts!",
            "What do you call fake spaghetti? An impasta!",
            "Why don't some couples go to the gym? Because some relationships don't work out!"
        ]
        joke = random.choice(jokes)
        speak(joke)
        return joke
        
    # New commands
    elif "take photo" in command or "take picture" in command or "take a photo" in command or "take a picture" in command:
        return take_photo()
    
    elif "run program" in command or "start program" in command or "open program" in command:
        program = command.replace("run program", "").replace("start program", "").replace("open program", "").strip()
        return run_program(program)
    
    elif "find file" in command or "search file" in command or "locate file" in command:
        file_pattern = command.replace("find file", "").replace("search file", "").replace("locate file", "").strip()
        return find_file(file_pattern)
    
    
    elif "search google" in command or "google search" in command:
        search_term = command.replace("search google", "").replace("google search", "").strip()
        return search_google(search_term)

    else:
        return "Command not recognized"

@app.route("/", methods=["GET"])
def home():
    """Returns API status and local IP."""
    return jsonify({
        "message": "Flask API is running",
        "device_ip": get_local_ip(),
        "status": "active"
    })

@app.route("/app")
def h():
    return render_template("index.html")

@app.route("/execute", methods=["POST"])
def execute():
    """Handles POST requests from Flutter and executes commands."""
    try:
        data = request.json
        command = data.get("command", "").lower()
        response = execute_command(command)
        return jsonify({"response": response})
    except Exception as e:
        return jsonify({"error": str(e)})

if __name__ == "__main__":
    local_ip = get_local_ip()
    print(f"Server running on http://{local_ip}:5000")
    app.run(host="0.0.0.0", port=5000, debug=True)
