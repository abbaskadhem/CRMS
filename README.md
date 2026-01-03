# S4 - Group 2

## App Name  
**CRMS (Campus Repair & Maintenance System)**

---

## Group Members

1. **Abbas Kadhem** - 202303883  
2. **Hoor Hasan** - 202301820  
3. **Maryam Abdulla** - 202302082  
4. **Reem Janahi** - 202101912  
5. **Yomna AlMubarak** - 202306219  
6. **Maha Hafeez** - 202200228  

---

## Main Features  

### Abbas Kadhem  
1. Submitting a Request  
2. Ticket Management (Admin)  

### Hoor Hasan  
1. User Login and Account Authentication  
2. Admin Dashboard with Analytics (Time, Category, Requests, Escalation)  

### Maryam Abdulla  
1. Settings Page  
2. Technician Schedule Overview  

### Reem Janahi  
1. Inventory Management  
2. Send Announcements & Notifications  

### Yomna AlMubarak  
1. Ticket Management for Servicer  
2. Ticket Management for Requester  

### Maha Hafeez  
1. Manage FAQs  
2. Category Management  

---

## Extra Features  

### Hoor Hasan  
1. Export Analytics as PDF  
2. Biometric Authentication using Face ID / Touch ID  

---

## Design Changes  

### User Login and Account Authentication  
The OTP verification function has been removed from the final app due to a Firebase limitation, which lacks built-in support for this feature. Implementing it would require extended development time and could incur additional costs.  

### Admin Dashboard with Analytics  
- Replaced buttons with segmented control based on tutor prototype feedback for easier navigation and improved user experience.  
- Added a **"Cancelled"** status section.  
- Added **percentage labels** to each slice of the pie chart for better visualization.  
- Changed the representation of request counts from percentages to actual numbers, allowing the admin to see both the percentage (in the chart) and the count (below).  

### Request Details  
Replaced the exclamation icon used for escalations with a clock icon to provide a holistic history view that includes escalation details.  

### Request Card  
Replaced background with white for improved visibility and aesthetics.  

---

## Libraries  

- **DGCharts:** [https://github.com/danielgindi/Charts.git](https://github.com/danielgindi/Charts.git)  
- **FSCalendar:** [https://github.com/WenchaoD/FSCalendar](https://github.com/WenchaoD/FSCalendar)  

---

## Simulators Used for Testing  

- iPhone 16 Pro  

---

## Admin Login Credentials  

- **Email:** [hoor.yousif05@gmail.com](mailto:hoor.yousif05@gmail.com)  
- **Password:** `hoor123`



