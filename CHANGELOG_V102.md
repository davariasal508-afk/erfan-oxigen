# ERFAN OXIGEN V102 – Requested Changes

- XP/Level/Badge system removed from the active product UI and scoring flow.
- Exam scoring moved to a teacher proposal -> admin review -> optional publish workflow.
- Student sees a score only after teacher requests publication and the admin approves it.
- Admin can adjust the proposed score up/down, approve hidden/public, or reject with a note.
- Theory exams can be built as real question sets; example: 20 questions = 10 multiple choice + 10 descriptive.
- Multiple-choice questions are auto-checked; descriptive questions remain for teacher review.
- Student identity fields added: student phone, father/guardian phone, national ID. These become locked after registration.
- Customer phone registry activated; registered customer can request a verification code and enter the customer area. SMS provider integration is still a separate production step; current app uses a local/dev OTP.
- 30-day automatic session expiry removed. Users stay logged in until they explicitly log out or the account is disabled.
- Chat separated into Private and Groups.
- Students can start private chats with teachers and the senior account; teachers can chat with the senior account and students.
- Admin can see who has viewed a chat thread.
- Class schedule is editable only by admin.
- Schedule changes create notifications for teachers/students.
- Admin can see who has viewed each schedule item.
- Admin display name remains configurable; default is «عرفان».
