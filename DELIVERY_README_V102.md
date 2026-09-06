# ERFAN OXIGEN V102

## Major product changes requested by client

1. XP / Level / Badge system removed from active product. Scoring is now the only grading mechanism.
2. Exam grading workflow:
   - Teacher proposes a 0–20 score.
   - Teacher can request that the score be shown to the student.
   - Senior user receives a notification.
   - Senior user can accept, increase/decrease, publish/hide, or reject the score.
   - Student sees the score only after publication.
3. Theory exam builder supports real questions, e.g. 20 questions = 10 multiple-choice + 10 descriptive.
   - Multiple-choice answers can be auto-checked.
   - Descriptive answers remain for teacher review.
4. Practical exams remain teacher-scored.
5. Student registration now records student phone, father/guardian phone and national ID. These identity fields are locked after registration.
6. Customer registry is controlled by the senior user. A registered customer can request a verification code and enter the customer area.
7. 30-day automatic logout was removed. User sessions persist until explicit logout or account deactivation.
8. Chat has separate Private and Group tabs.
   - Student: private chat with teachers and the senior account.
   - Teacher: private chat with the senior account and students.
   - Supported attachments include image, file/PDF, audio, sticker and video up to 60 seconds.
   - Admin can inspect who viewed a conversation thread.
9. Class schedule is editable only by the senior account.
   - Changes notify active teachers/students.
   - Admin can inspect who viewed each schedule item.
10. Senior account display name remains configurable; default is «عرفان».

## Important note about customer OTP
The current build has a working local/demo OTP flow. It does not send real SMS because no SMS gateway credentials/provider were configured. Production SMS requires connecting an SMS provider later.

## Run

```powershell
cd E:\Projects\Oxygen
flutter pub get
flutter analyze
flutter run
```

## Server
The existing backend/Tailscale files from V101 are retained. The application can continue using local storage when the backend is disabled.
