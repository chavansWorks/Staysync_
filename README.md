# StaySync 🏢🔐
*A Flutter-based Community Management Application*

---

## 1.2 OBJECTIVE  

The **StaySync application** is developed with the following objectives:  

- 🔒 Enhancing **security** through a QR-based entry system for residents, visitors, and staff.  
- 🧾 Automating **visitor tracking** and temporary pass management for short-term guests.  
- 📲 Providing **real-time notifications** for deliveries, maintenance updates, security alerts, and community announcements.  
- 👩‍💼 Digitizing **staff attendance tracking** for maids, security guards, and other personnel.  
- 📊 Allowing **bulk registration** of residents and staff using Excel file imports to streamline onboarding.  
- 🛠 Enabling **transparent maintenance tracking** for residents to report issues, check status updates, and receive notifications.  
- 💰 Providing **financial transparency** by managing monthly maintenance fees and shared expenses.  

---

## 1.3 SCOPE, PURPOSE, APPLICABILITY  

### 1.3.1 SCOPE  
StaySync is designed to serve:  
- Residential buildings  
- Apartment complexes  
- Gated communities  

It functions as a **digital management system** for:  
- Security  
- Staff attendance  
- Maintenance tracking  
- Expense management  

### 1.3.2 PURPOSE  
The StaySync application serves the following purposes:  

- ✅ Improving **security** by tracking visitors, staff, and service personnel.  
- ✅ Automating the **check-in/check-out process** using QR-based authentication.  
- ✅ Providing an **effective communication channel** for announcements, maintenance updates, and alerts.  
- ✅ Ensuring **seamless management** of residents and staff through digital records and real-time updates.  
- ✅ Enabling **financial transparency** with structured expense-tracking for maintenance and shared costs.  

---

## 2. FEATURES CHECKLIST  

| Feature                               | Status        | Notes |
|---------------------------------------|--------------|-------|
| QR-based entry system                 | ✅ Completed | Secure authentication for residents & visitors |
| Visitor management & temporary passes | ✅ Completed | Auto-tracking for short-term guests |
| Real-time notifications               | ✅ Completed | Deliveries, maintenance, alerts |
| Staff attendance tracking             | ✅ Completed | Maids, guards, service personnel |
| Bulk registration via Excel import    | ✅ Completed | For residents & staff onboarding |
| Maintenance issue reporting           | ✅ Completed | Transparent ticket tracking |
| Financial expense management          | ✅ Completed | Monthly fees & shared costs |

---

## 3. TECH STACK  

- **Flutter** – Cross-platform mobile development  
- **Dart** – Programming language  
- **Firebase / Node.js** – Backend services (Auth, DB, Notifications)  
- **MySQL / Firestore** – Data storage  
- **Excel Import** – Bulk onboarding tool  

---

## 4. PROJECT SETUP  

```bash
# Clone the repository
git clone https://github.com/yourusername/staysync.git

# Navigate to project folder
cd staysync

# Install dependencies
flutter pub get

# Run the app
flutter run
