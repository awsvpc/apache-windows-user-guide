# Apache Upgrade Notes (Windows)

## Assumptions

| Item                 | Value                           |
| -------------------- | ------------------------------- |
| Service Name         | Apache24                        |
| Current Installation | `D:\Program Files\Apache24`     |
| Backup Installation  | `D:\Program Files\Apache24_OLD` |

---

# 1. Verify Current Installation

### Check Apache version

```cmd
"D:\Program Files\Apache24\bin\httpd.exe" -v
```

### Check configuration

```cmd
"D:\Program Files\Apache24\bin\httpd.exe" -t
```

### Check virtual hosts

```cmd
"D:\Program Files\Apache24\bin\httpd.exe" -S
```

### Check loaded modules

```cmd
"D:\Program Files\Apache24\bin\httpd.exe" -M
```

### Check service configuration

```cmd
sc qc Apache24
```

### Check service status

```cmd
sc query Apache24
```

---

# 2. Stop Service

```cmd
net stop Apache24
```

Verify:

```cmd
sc query Apache24
```

Expected:

```text
STATE : STOPPED
```

---

# 3. Backup Existing Installation

Rename current installation:

```cmd
ren "D:\Program Files\Apache24" Apache24_OLD
```

---

# 4. Archive Backup (Optional)

## PowerShell

```powershell
$Date = Get-Date -Format "MMddyyyy"

Compress-Archive `
    -Path "D:\Program Files\Apache24_OLD" `
    -DestinationPath "D:\Program Files\Apache24_OLD_$Date.zip"
```

Example:

```text
Apache24_OLD_06222026.zip
```

---

# 5. Install New Apache

Extract the new Apache ZIP into:

```text
D:\Program Files\Apache24
```

Verify structure:

```text
D:\Program Files\Apache24\bin
D:\Program Files\Apache24\conf
D:\Program Files\Apache24\modules
```

---

# 6. Copy Production Configuration

Copy entire `conf` directory:

```cmd
robocopy ^
"D:\Program Files\Apache24_OLD\conf" ^
"D:\Program Files\Apache24\conf" ^
/E
```

---

# 7. Copy Website Content

```cmd
robocopy ^
"D:\Program Files\Apache24_OLD\htdocs" ^
"D:\Program Files\Apache24\htdocs" ^
/E /XO
```

---

# 8. Copy CGI Scripts

```cmd
robocopy ^
"D:\Program Files\Apache24_OLD\cgi-bin" ^
"D:\Program Files\Apache24\cgi-bin" ^
/E /XO
```

---

# 9. Copy Missing Files from MODULES

### Preview only

```cmd
robocopy ^
"D:\Program Files\Apache24_OLD\modules" ^
"D:\Program Files\Apache24\modules" ^
*.* /E /XC /XN /XO /L
```

### Copy missing files

```cmd
robocopy ^
"D:\Program Files\Apache24_OLD\modules" ^
"D:\Program Files\Apache24\modules" ^
*.* /E /XC /XN /XO
```

---

# 10. Copy Missing Files from LIB

### Preview only

```cmd
robocopy ^
"D:\Program Files\Apache24_OLD\lib" ^
"D:\Program Files\Apache24\lib" ^
*.* /E /XC /XN /XO /L
```

### Copy missing files

```cmd
robocopy ^
"D:\Program Files\Apache24_OLD\lib" ^
"D:\Program Files\Apache24\lib" ^
*.* /E /XC /XN /XO
```

---

# 11. Copy Missing Files from LOGS

### Preview only

```cmd
robocopy ^
"D:\Program Files\Apache24_OLD\logs" ^
"D:\Program Files\Apache24\logs" ^
*.* /E /XC /XN /XO /L
```

### Copy missing files excluding *.log

```cmd
robocopy ^
"D:\Program Files\Apache24_OLD\logs" ^
"D:\Program Files\Apache24\logs" ^
*.* /E /XC /XN /XO /XF *.log
```

---

# 12. Validate New Installation

### Syntax check

```cmd
"D:\Program Files\Apache24\bin\httpd.exe" -t
```

Expected:

```text
Syntax OK
```

### Check virtual hosts

```cmd
"D:\Program Files\Apache24\bin\httpd.exe" -S
```

### Check modules

```cmd
"D:\Program Files\Apache24\bin\httpd.exe" -M
```

### Check version

```cmd
"D:\Program Files\Apache24\bin\httpd.exe" -v
```

---

# 13. Start Service

```cmd
net start Apache24
```

Verify:

```cmd
sc query Apache24
```

Expected:

```text
STATE : RUNNING
```

---

# 14. Review Error Log

### View file

```cmd
type "D:\Program Files\Apache24\logs\error.log"
```

### Follow log in PowerShell

```powershell
Get-Content `
"D:\Program Files\Apache24\logs\error.log" `
-Wait
```

---

# 15. Rollback Procedure

### Stop service

```cmd
net stop Apache24
```

### Rename failed installation

```cmd
ren "D:\Program Files\Apache24" Apache24_FAILED
```

### Restore backup

```cmd
ren "D:\Program Files\Apache24_OLD" Apache24
```

### Start service

```cmd
net start Apache24
```

### Verify

```cmd
sc query Apache24
```

---

# Recommended Upgrade Order

1. Verify current installation
2. Stop Apache service
3. Rename `Apache24` → `Apache24_OLD`
4. Create optional ZIP archive
5. Extract new Apache ZIP
6. Copy `conf`
7. Copy `htdocs`
8. Copy `cgi-bin`
9. Copy missing `modules`
10. Copy missing `lib`
11. Validate configuration
12. Start service
13. Review logs
14. Keep `Apache24_OLD` until upgrade is confirmed successful

---

# Rollback Trigger Conditions

Rollback immediately if any of the following occur:

* `httpd.exe -t` fails
* Service fails to start
* SSL certificates fail to load
* Virtual hosts fail validation
* Application returns HTTP 500 errors
* Critical modules fail to load

Rollback command sequence:

```cmd
net stop Apache24

ren "D:\Program Files\Apache24" Apache24_FAILED

ren "D:\Program Files\Apache24_OLD" Apache24

net start Apache24
```
