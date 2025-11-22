# Document Persistence & Delete Feature

## Overview
Documents uploaded through the app are now persisted in a Supabase PostgreSQL `documents` table. This ensures that:
- Documents remain available even after the app is restarted
- Users can delete documents they've uploaded
- Document metadata (uploader, timestamp) is maintained

## Implementation

### 1. Database Schema (`sql_migrations/001_create_documents_table.sql`)
The `documents` table structure:
```sql
CREATE TABLE documents (
  id bigserial primary key,
  course_title text not null,        -- Links document to a course
  file_name text not null,           -- Original file name
  file_url text not null,            -- Public or signed URL to the file
  uploaded_by text not null,         -- User ID or email of uploader
  uploaded_at timestamp,             -- When the file was uploaded
  created_at timestamp default now() -- Auto-generated timestamp
);
```

**To create this table:**
1. Go to your Supabase project dashboard
2. Open the SQL Editor
3. Copy the contents of `sql_migrations/001_create_documents_table.sql`
4. Run the SQL query

Alternatively, the app will attempt to create the table on first document save if needed (may fail with permission error, in which case manually run the SQL).

### 2. DocumentRetrievalHelper (`lib/document_retrieval_helper.dart`)
Helper class that manages all document CRUD operations:

#### Methods:

**`fetchDocumentsForCourse(courseTitle)`**
- Loads all documents for a specific course from the database
- Returns a list of `CourseDocument` objects
- Called automatically when the course detail page loads

**`saveDocument({courseTitle, fileName, fileUrl, uploadedBy})`**
- Saves a newly uploaded document to the database
- Called after successful upload in `_pickAndUploadFiles()`
- Gracefully fails without blocking the app if the database is unavailable

**`deleteDocument({courseTitle, fileName, fileUrl, deleteFromStorage})`**
- Deletes a document from the database table
- Optionally deletes the file from Supabase Storage (default: true)
- Called when user clicks the delete button on a document card

**`populateDocumentsForCourse(course)`**
- Loads documents into a Course object's `.documents` list
- Used for batch operations

**`fetchDocumentsForAllCourses(courses)`**
- Bulk loads documents for multiple courses
- Returns a map of `courseTitle -> List<CourseDocument>`

### 3. UI Integration (`lib/course_detail_page.dart`)

#### On Page Load
```dart
@override
void initState() {
  super.initState();
  // ... existing code ...
  _loadDocuments(); // Load persisted documents from Supabase
}

Future<void> _loadDocuments() async {
  final docs = await DocumentRetrievalHelper.fetchDocumentsForCourse(widget.course.title);
  setState(() => widget.course.documents = docs);
}
```

#### On Upload
After successful file upload to Supabase Storage:
```dart
// Save to persistent storage
await DocumentRetrievalHelper.saveDocument(
  courseTitle: widget.course.title,
  fileName: filename,
  fileUrl: fileUrl,
  uploadedBy: uploaderId,
);
```

#### Delete Button
Each document card now shows a delete button (trash icon):
```dart
IconButton(
  icon: const Icon(Icons.delete_outline),
  tooltip: 'Delete',
  onPressed: () => _deleteDocument(d.name, d.url),
)
```

The `_deleteDocument()` method:
1. Shows a confirmation dialog
2. Calls `DocumentRetrievalHelper.deleteDocument()` to remove from DB and storage
3. Updates the UI to remove the document from the list
4. Shows a success/error message

## Error Handling

### Database Table Not Found
If the `documents` table doesn't exist when saving:
- The app will attempt to create it automatically (if permissions allow)
- If auto-creation fails, the document is still saved in memory (app-level)
- On next app restart, the document will no longer appear (only in-memory docs persist)
- **Solution:** Run the SQL migration manually in Supabase SQL Editor

### Upload Success, DB Save Fails
If a file uploads successfully but the database save fails:
- Document appears in the UI and app state
- Refresh app → document disappears (not in database)
- **Resolution:** Check Supabase database status and RLS policies

### Permission Errors
Ensure Supabase RLS policies allow:
- Authenticated users to INSERT documents
- Authenticated users to SELECT documents
- Users to DELETE their own documents (based on `uploaded_by`)

See the SQL migration file for example RLS policies.

## Usage Flow

1. **Upload Document**
   - User picks file from device
   - File uploads to Supabase Storage
   - Document record saved to `documents` table
   - UI updated with new document in course details

2. **View Documents**
   - Course detail page loads
   - `_loadDocuments()` queries Supabase for all documents in that course
   - Documents displayed in styled cards with metadata
   - Download and delete buttons available

3. **Download Document**
   - User clicks download button
   - App opens file URL in browser/external app
   - File is downloaded or previewed in system default handler

4. **Delete Document**
   - User clicks delete button
   - Confirmation dialog appears
   - On confirm:
     - Document record deleted from database
     - File deleted from Supabase Storage
     - UI refreshed to remove document card

## Environment Variables
No new environment variables required. The app uses existing:
- `SUPABASE_URL` — Supabase project URL
- `SUPABASE_ANON_KEY` — Anonymous API key
- `SUPABASE_STORAGE_BUCKET` — Storage bucket name (defaults to `bucket1`)

## Testing

1. **Setup:**
   - Create the `documents` table via SQL migration (or let app auto-create)
   - Ensure Supabase Storage bucket exists and has RLS policies configured

2. **Upload & Persist:**
   - Open Course Details page
   - Click "Choose Files" and select a document
   - Verify document appears in UI
   - Close and reopen the app
   - Verify document still appears (loaded from database)

3. **Delete:**
   - Click delete button on any document
   - Confirm deletion in dialog
   - Verify document disappears from UI
   - Verify file is removed from Supabase Storage

4. **Edge Cases:**
   - Upload with no internet → error shown, document in memory only
   - Delete with network failure → error shown, document remains
   - Multiple users uploading to same course → each sees all documents

## Future Enhancements

- Add document tagging/categorization
- Search/filter documents by name or uploader
- Share documents between courses
- Add document version history
- Restrict delete permission to document owner + course instructor
