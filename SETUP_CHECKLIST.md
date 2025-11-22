# Quick Setup Checklist

## Before Testing the Document Persistence Feature

### 1. ✅ Supabase Table Setup (REQUIRED)
- [ ] Open Supabase dashboard for your project (xgecdpvziuvwyqmrejvn)
- [ ] Navigate to SQL Editor
- [ ] Create new query
- [ ] Copy/paste contents of `sql_migrations/001_create_documents_table.sql`
- [ ] Execute the query
- [ ] Verify the `documents` table appears in the Tables list
- [ ] Run test query: `SELECT * FROM documents;` (should return empty table)

**If table creation fails with permission error:**
- [ ] Contact Supabase support or check database role permissions
- [ ] Alternative: The app will attempt auto-creation on first document save (may also fail with same error)
- [ ] Create table manually via Supabase dashboard UI if SQL fails

### 2. ✅ RLS Policies (REQUIRED for authenticated access)
The SQL migration includes RLS policies. Verify they exist:
- [ ] Navigate to Authentication → Policies in Supabase dashboard
- [ ] Select the `documents` table
- [ ] Verify three policies exist:
  1. "Allow authenticated users to insert documents" (INSERT)
  2. "Allow authenticated users to read documents" (SELECT)
  3. "Allow users to delete their own documents" (DELETE)

**If policies are missing:**
- [ ] Re-run the SQL migration (second half with CREATE POLICY statements)
- [ ] Or create policies manually in Supabase dashboard UI

### 3. ✅ App Code Verification
- [ ] Verify `lib/document_retrieval_helper.dart` exists and compiles
- [ ] Verify `lib/course_detail_page.dart` includes `_loadDocuments()` method
- [ ] Verify `_deleteDocument()` method exists in `course_detail_page.dart`
- [ ] Run `flutter pub get` to ensure all dependencies are up-to-date
- [ ] Verify no compilation errors: `flutter analyze`

### 4. ✅ Environment Variables
- [ ] Verify `.env` file exists at project root with:
  - [ ] `SUPABASE_URL=https://xgecdpvziuvwyqmrejvn.supabase.co`
  - [ ] `SUPABASE_ANON_KEY=eyJ...` (your actual key)
  - [ ] `SUPABASE_STORAGE_BUCKET=bucket1`

### 5. ✅ Storage Bucket (should already exist)
- [ ] Open Supabase Storage
- [ ] Verify `bucket1` bucket exists
- [ ] Verify RLS policies on `bucket1` allow authenticated INSERT/SELECT
- [ ] (Optional) Check that `authenticated` role has these policies

---

## Testing Flow

### Test 1: Upload & Immediate Display
1. [ ] Launch app on device
2. [ ] Navigate to any course → Course Details
3. [ ] Click "Choose Files"
4. [ ] Select a test file (PDF, image, etc.)
5. [ ] Verify file appears in "Documents" section
6. [ ] Expected: Document appears with metadata (name, uploader, date)

### Test 2: Persistence Across Restart
1. [ ] Document uploaded (from Test 1)
2. [ ] Close app completely
3. [ ] Reopen app
4. [ ] Navigate to same course → Course Details
5. [ ] Expected: Document appears (loaded from Supabase database)

### Test 3: Delete Functionality
1. [ ] Document visible (from Test 2)
2. [ ] Click trash icon on document card
3. [ ] Confirmation dialog appears
4. [ ] Click "Delete" button
5. [ ] Expected: Document disappears from UI, success message shown
6. [ ] Verify in Supabase:
   - [ ] Go to SQL Editor
   - [ ] Run: `SELECT * FROM documents;`
   - [ ] Verify deleted document no longer in table

### Test 4: Multiple Documents
1. [ ] Upload 3 different files to same course
2. [ ] All should appear in Documents section
3. [ ] Restart app
4. [ ] All documents should still appear
5. [ ] Delete one document
6. [ ] Two documents should remain
7. [ ] Restart app
8. [ ] Verify 2 documents still remain (3rd deleted)

### Test 5: Download Still Works
1. [ ] Document visible in UI
2. [ ] Click download button
3. [ ] File should open/download in system default handler
4. [ ] Expected: PDF viewer, file manager, or browser depending on file type

---

## Troubleshooting

### Problem: Documents not persisting after restart
**Checklist:**
- [ ] Is `documents` table created in Supabase? (check SQL Editor → Tables)
- [ ] Does table have data? (run `SELECT * FROM documents;` in SQL Editor)
- [ ] Are RLS policies enabled? (check Authentication → Policies)
- [ ] Check device console for errors: `flutter logs`

### Problem: "Permission Denied" or "403 Unauthorized" error
**Checklist:**
- [ ] Did you add RLS policies to `documents` table?
- [ ] Is the policy set to allow `auth.role() = 'authenticated_user'`?
- [ ] Are you logged in to the app with a valid Supabase user?
- [ ] Check `.env` for correct `SUPABASE_ANON_KEY`

### Problem: Upload succeeds but document doesn't appear after restart
**Likely Cause:** Database save failed silently (app shows success but DB save errored)
**Debug Steps:**
1. [ ] Run `flutter logs` while uploading
2. [ ] Look for error messages from `DocumentRetrievalHelper`
3. [ ] Check Supabase database logs (if available in project settings)
4. [ ] Manually verify data in table: `SELECT * FROM documents;`

### Problem: Delete button clicked but document still there
**Debug Steps:**
1. [ ] Check if confirmation dialog appeared (did you actually click Delete in dialog?)
2. [ ] Check device console for errors in `_deleteDocument()` method
3. [ ] Verify RLS policy for DELETE exists and is correct
4. [ ] Manually delete from DB: Run `DELETE FROM documents WHERE file_name = 'test.pdf';` in SQL Editor

---

## Support

For issues or questions:
1. Check `DOCUMENT_PERSISTENCE.md` for detailed documentation
2. Review `IMPLEMENTATION_SUMMARY.md` for code structure
3. Check Flutter logs: `flutter logs`
4. Verify Supabase project status: https://xgecdpvziuvwyqmrejvn.supabase.co/
5. Contact project maintainers

---

## Quick Command Reference

**Check compilation:**
```bash
flutter analyze
```

**Run app:**
```bash
flutter run -d <device_id>
```

**View logs:**
```bash
flutter logs
```

**Check database (in Supabase SQL Editor):**
```sql
SELECT * FROM documents;
SELECT COUNT(*) FROM documents;
SELECT DISTINCT course_title FROM documents;
```

**Force hot reload after changes to helper:**
```bash
flutter hot-reload  # May need full rebuild if database layer changed
```
