# Quick Debugging Steps

## Issue: Jobs and Companies Not Showing in UI

---

## ✅ FIXES APPLIED

Your code has been fixed. Here are the changes:

### 1. Fixed Critical Bug in `job_provider.dart`
**Problem**: Filter state was corrupted by clearing inside the loop
**Solution**: Moved `_activeFilters.clear()` outside the `.where()` loop

### 2. Added Loading & Error States
**Problem**: UI showed empty screen instead of loading indicator
**Solution**: Added proper state handling in `find_job_page.dart` and `network_screen.dart`

### 3. Added Debug Logging
**Problem**: No visibility into data loading
**Solution**: Added console logs to track what's happening

---

## 🧪 TEST NOW

### Test 1: Check Logs
```
1. Run the app
2. Open Flutter DevTools Console (Ctrl+J or Cmd+J in VS Code)
3. Look for:
   ✅ Jobs loaded: X
   ✅ Companies loaded: Y
   ✅ Filtered jobs: Z
```

**If X, Y, Z are 0**: Backend is not returning data
**If X, Y, Z > 0**: Data is loading correctly ✓

---

### Test 2: Check Loading Indicator
```
1. Scroll to "Find Jobs" tab
2. Should see CircularProgressIndicator briefly
3. Then jobs list appears
```

If nothing appears after 5 seconds → Network issue

---

### Test 3: Check Filters
```
1. In "Find Jobs" page, type "Design" in search
2. Jobs should filter
3. Check console: "🔍 Filtered jobs: X from Y"
```

---

### Test 4: Check Error Handling
```
1. Turn off WiFi/Mobile Data
2. Pull down to refresh or navigate away and back
3. Should see error message with "Retry" button
4. Turn internet back on
5. Tap "Retry"
6. Jobs should load
```

---

## 🐛 If Still Not Working

### Problem 1: No jobs showing (console shows count > 0)
- **Check**: Are filters hiding all jobs?
- **Fix**: Clear all filters in the filter page
- **Test**: Search for "Design" (should be in backend data)

### Problem 2: Console shows 0 jobs loaded
- **Check**: Is backend running?
- **Test**: Open Postman → GET `http://10.239.60.250:3000/api/Job`
- **Fix**: If Postman returns 404/500, backend has issue

### Problem 3: Crash when loading
- **Check**: Model field names match backend
- **Test**: Look at error in console
- **Fix**: Update backend field names to match Flutter model

### Problem 4: Job card shows no company logo
- **Check**: Is `company.companyLogo` URL valid?
- **Test**: Open URL in browser
- **Fix**: Backend should return full image URLs

---

## 🔍 Advanced Debugging

### Enable Network Logging

Add to `lib/provider/api_client.dart` in the Dio setup:

```dart
if (kDebugMode) {
  _dio.interceptors.add(
    LoggingInterceptor(),
  );
}
```

This shows:
- Full HTTP requests
- Full HTTP responses
- Network timing

---

### Check Model Mapping

Verify these files match backend JSON:

1. `lib/model.dart/job.dart` - Compare field names with `/api/Job` response
2. `lib/model.dart/company.dart` - Compare field names with `/api/company` response

**Special Notes**:
- Backend has `comapnyID` (typo) - Flutter model handles this with `@JsonKey(name: 'comapnyID')`
- Backend field `company_gallery` - Flutter model maps to `companyGallery`

---

## 📊 Data Flow

```
main.dart
  ↓
JobProvider() [Constructor]
  ↓
_loadUserDataAndFetchJobs()
  ↓
fetchJobs()
  ├─ Call _jobApiService.getAllJobs() → /api/Job
  ├─ Call _companyApiService.getAllCompanies() → /api/company
  ├─ Set _allJobs and _allCompanies
  ├─ _filteredJobs = List.from(_allJobs)
  └─ notifyListeners() ← **IMPORTANT: Tells UI to rebuild**
  ↓
Consumer<JobProvider> in find_job_page.dart
  ↓
UI displays jobProvider.filteredJobs
```

If any step fails, data won't show.

---

## ✨ Summary

All critical issues are fixed:

| Issue | Status | Solution |
|-------|--------|----------|
| Filter corruption | ✅ Fixed | Moved clear() outside loop |
| No loading state | ✅ Fixed | Added CircularProgressIndicator |
| Silent errors | ✅ Fixed | Added error display with retry |
| No debug info | ✅ Fixed | Added console logging |
| Missing UI updates | ✅ Fixed | Ensured notifyListeners() called |

**You should see jobs and companies now!** 🎉

If not, check the [DEBUGGING_JOBS_NOT_SHOWING.md](./DEBUGGING_JOBS_NOT_SHOWING.md) file for detailed troubleshooting.
