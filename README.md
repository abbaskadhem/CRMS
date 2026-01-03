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

### Abbas Kadhem
1. Request History viewing and record keeping

---

## Design Changes  

### User Login and Account Authentication  
The OTP verification function has been removed from the final app due to Firebase limitations, which lack built-in support for this feature. Implementing it would require extended development time and may incur additional costs.  

### Admin Dashboard with Analytics  
- Replaced buttons with segmented controls based on tutor prototype feedback for better navigation and usability.  
- Added a **"Cancelled"** status section.  
- Added **percentage labels** to pie chart slices for improved data visualization.  
- Changed the representation of requests from percentages to actual counts — percentages are shown in the chart and numbers below.  

### Request Details  
Replaced the exclamation icon for escalations with a clock icon to present a holistic history view that includes escalation details.  

### Request Card  
Replaced the background with white to enhance visibility and aesthetics.  

### Settings Page  
Initially planned to use a `UITableView` to match the prototype, but due to technical limitations with cell configuration and selection handling, the team used standard `UIView` components. Minor style changes were applied to the appearance and background to maintain a modern look and ease of maintainability.  

### Inventory Management Page  
Combined the “Add Category” and “Add Subcategory” buttons into a single **+** button following tutor feedback.  

### Notification Page  
- Repositioned the date from the right side to the left, replacing it with an icon representing the notification type.  
  - **Megaphone:** Announcement  
  - **Bell:** Notification  
- Added a **Clear Filter** button to reset date filters.  
- Adjusted layout to address fixed navigation bar issues and improved visual balance.  
- Moved the creation date to the left and replaced the edit icon with a simpler pencil design.  
- Editing an announcement now redirects to the **Create Announcement** page since every update is considered a new entry.  

### Dropdown → List View  
This redesign was guided by usability and scalability rather than functional changes.  
It enhances interface intuitiveness, simplifies user interactions, and ensures consistency with iOS platform standards.  
Additionally, it improves maintainability and supports future feature expansion without major UI overhauls.  

---

## Libraries  

- **DGCharts:** [https://github.com/danielgindi/Charts.git](https://github.com/danielgindi/Charts.git)  
- **FSCalendar:** [https://github.com/WenchaoD/FSCalendar](https://github.com/WenchaoD/FSCalendar)  

---

## Simulator Used  

- iPhone 16 Pro  

---

## Admin Login Credentials  

- **Email:** [hoor.yousif05@gmail.com](mailto:hoor.yousif05@gmail.com)  
- **Password:** `hoor123`
