# Firebase configuration notes

- Register Android package: `com.otplus.app`
- Enable Firebase Authentication provider(s) before posting jobs.
- Create Firestore database.
- Deploy `firestore.rules` with Firebase CLI.
- The current rules let signed-in users submit posts as `pending`; only an admin process should change status to `published`.
- This starter does not include an admin panel or admin custom claims yet. Do not manually expose privileged credentials in the mobile app.
- Public list query filters `status == published` and orders by `createdAt`; Firestore may ask to create a composite index from its error link.
