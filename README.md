🚀 MediVue (Rebrand Suggested: MediVue Care / CareVue IoT)
Smart Health Monitoring System for Elderly (IoT + MERN Stack)

🧠 Overview
MediVue is an IoT-based healthcare monitoring system designed to provide real-time health tracking and emergency response for elderly individuals (60+ age group).
The system integrates hardware sensors (ESP32 + MAX30102 + Temperature Sensor) with a MERN Stack web application to deliver:


Real-time vitals monitoring


Emergency alerts


Doctor dashboard


Patient management system



🎯 Problem Statement
Many elderly individuals live alone without continuous supervision.
Critical health issues such as:


Sudden heart rate spikes


Low oxygen levels (SpO2)


High body temperature


Accidental falls


can become life-threatening if not detected immediately.

💡 Solution
MediVue provides a smart, connected ecosystem where:


IoT sensors collect real-time health data


Data is sent to a backend server


Caregivers and doctors monitor through a web/mobile dashboard


Alerts are triggered automatically in emergencies



🏗️ System Architecture
[ Sensors (ESP32 + MAX30102 + Temp Sensor) ]                ↓         WiFi / HTTP / MQTT                ↓        Node.js Backend API                ↓           MongoDB Database                ↓        React Dashboard (Doctor / Caregiver)

🔥 Key Features
❤️ Real-Time Health Monitoring


Heart Rate Monitoring (MAX30102)


SpO2 (Blood Oxygen Level)


Body Temperature Tracking



🚨 Emergency Alert System


Detect abnormal vitals


Automatic alert notifications


Emergency call trigger to caregiver



🧍 Fall Detection System


Detect sudden movement/impact


Send instant alert to app



👨‍⚕️ Doctor Dashboard


View all patients


Real-time vitals monitoring


Access patient history


Add / manage patients



📊 Data Visualization


Graphs for health trends


Daily / weekly monitoring


Health analytics



🔐 Authentication System


Login for doctors & caregivers


Secure access control



🛠 Tech Stack
💻 Frontend


React.js


Redux (State Management)


Tailwind CSS / Material UI


⚙ Backend


Node.js


Express.js


🗄 Database


MongoDB (Mongoose)


📡 IoT Layer


ESP32


MAX30102 Sensor


Temperature Sensor


🔗 Communication


REST API / MQTT (optional upgrade)



📁 Project Structure
MediVue/│├── client/               # React Frontend│   ├── src/│   ├── components/│   ├── pages/│├── server/               # Node.js Backend│   ├── controllers/│   ├── models/│   ├── routes/│   ├── middleware/│├── hardware/             # ESP32 Code│   ├── sensor_code.ino│├── docs/                 # Architecture & Images│└── README.md

⚙️ Installation & Setup
🔹 Clone Repository
git clone https://github.com/yourusername/medivue.gitcd medivue

🔹 Backend Setup
cd servernpm install
Create .env file:
PORT=5000MONGO_URI=your_mongodb_connectionJWT_SECRET=your_secret_key
Run backend:
npm run dev

🔹 Frontend Setup
cd clientnpm installnpm start

🔹 Hardware Setup


Connect MAX30102 to ESP32


Connect Temperature Sensor


Upload Arduino code


Configure WiFi credentials


Send data to backend API



📡 API Example
Send Health Data
POST /api/vitals{  "heartRate": 85,  "spo2": 97,  "temperature": 36.5,  "fallDetected": false}

🔮 Future Enhancements


📱 Mobile App (Flutter)


☁ Firebase / AWS integration


🤖 AI-based health prediction


📍 GPS tracking


🔔 Push notifications (FCM)


🧠 ML anomaly detection



⚠️ Note
This project was developed as part of:
🏆 Medha 2.0
Conducted by Lovely Professional University (LPU)
In collaboration with IIT Bombay

👨‍💻 Team


Ritik Raushan


Nilesh Gupta


Prabhnoor Singh


Vivek


Ayushman



📸 Demo
(Add screenshots / demo video here)

📜 License
This project is for academic and learning purposes.

🔥 BONUS (VERY IMPORTANT)
When you upload this on GitHub:
✔ Add screenshots
✔ Add demo video link
✔ Add APK / Web link
✔ Add proper repo name

⚡ If you want next level:
I can help you:
✅ Convert this into startup-level project
✅ Add real MERN backend code
✅ Build API endpoints
✅ Create React dashboard UI
✅ Connect ESP32 live data
✅ Make it deployable
Just say: “Build full MERN backend + frontend” 🚀
