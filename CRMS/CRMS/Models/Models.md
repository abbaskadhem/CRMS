//
//  Models.md
//  CRMS
//
//  Created by BP-36-201-10 on 01/12/2025.
//

## Entities/Tables
### Common fields
- Created on
- Created by
- Modified on
- Modified by
- Inactive

### Request
- UUID
- Request No.
- Requester Ref.
- Request Category Ref.
- Request Subcategory Ref.
- Building Ref.
- Room Ref.
- Description
- Images
- Priority
- Status
- Servicer Ref.
- Start Date
- End Date
- Owner ID
- Stars
- Feedback text

### Request History
- UUID
- Record No.
- Request Ref.
- Action
- Sent back reason
- Reassign reason
- Date/Time

### Users
- UUID
- User No.
- Full Name
- Type (Admin/Requester/Servicer)
- Subtype (For requesters/servicers to specify)
- Email
- Hashed Password

### Buildings
- UUID
- Building No

### Rooms
- UUID
- Room No.
- Building Ref.

### Request Categories
- UUID
- Name
- Is_Parent
- Parent Category Ref.

### FAQ
- UUID
- Question
- Answer

### Notifications/Announcements
- UUID
- Title
- Description
- To who
- Type
- Request Ref.

### Items Categories
- UUID
- Name
- Is_Parent
- Parent Category Ref.

### Item
- UUID
- Name
- Part No.
- Unit Cost
- Vendor
- Item Category Ref.
- Item Subcategory Ref.
- Quantity
- Description
- Usage
