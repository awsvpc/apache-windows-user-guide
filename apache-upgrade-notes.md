Apache Upgrade Notes (Windows)

Assumptions

Service Name:
Apache24

Current Installation:
D:\Program Files\Apache24

Backup Installation:
D:\Program Files\Apache24_OLD

---

1. Verify Current Installation

---

Check Apache version:

"D:\Program Files\Apache24\bin\httpd.exe" -v

Check configuration:

"D:\Program Files\Apache24\bin\httpd.exe" -t

Check virtual hosts:

"D:\Program Files\Apache24\bin\httpd.exe" -S

Check loaded modules:

"D:\Program Files\Apache24\bin\httpd.exe" -M

Check service configuration:

sc qc Apache24

Check service status:

sc query Apache24

---

2. Stop Service

---

net stop Apache24

Verify:

sc query Apache24

Expected:

STATE : STOPPED

---

3. Backup Existing Installation

---

Rename current installation:

ren "D:\Program Files\Apache24" Apache24_OLD

---

4. Archive Backup (Optional)

---

PowerShell:

$Date = Get-Date -Format "MMddyyyy"
Compress-Archive `-Path "D:\Program Files\Apache24_OLD"`
-DestinationPath "D:\Program Files\Apache24_OLD_$Date.zip"

Example:

Apache24_OLD_06222026.zip

---

5. Install New Apache

---

Extract new Apache ZIP into:

D:\Program Files\Apache24

Verify:

D:\Program Files\Apache24\bin
D:\Program Files\Apache24\conf
D:\Program Files\Apache24\modules

---

6. Copy Production Configuration

---

Copy entire conf directory:

robocopy `"D:\Program Files\Apache24_OLD\conf"`
"D:\Program Files\Apache24\conf" `
/E

---

7. Copy Website Content

---

robocopy `"D:\Program Files\Apache24_OLD\htdocs"`
"D:\Program Files\Apache24\htdocs" `
/E /XO

---

8. Copy CGI Scripts

---

robocopy `"D:\Program Files\Apache24_OLD\cgi-bin"`
"D:\Program Files\Apache24\cgi-bin" `
/E /XO

---

9. Copy Missing Files from MODULES

---

List missing files only:

robocopy `"D:\Program Files\Apache24_OLD\modules"`
"D:\Program Files\Apache24\modules" `
*.* /E /XC /XN /XO /L

Copy missing files:

robocopy `"D:\Program Files\Apache24_OLD\modules"`
"D:\Program Files\Apache24\modules" `
*.* /E /XC /XN /XO

---

10. Copy Missing Files from LIB

---

List missing files only:

robocopy `"D:\Program Files\Apache24_OLD\lib"`
"D:\Program Files\Apache24\lib" `
*.* /E /XC /XN /XO /L

Copy missing files:

robocopy `"D:\Program Files\Apache24_OLD\lib"`
"D:\Program Files\Apache24\lib" `
*.* /E /XC /XN /XO

---

11. Copy Missing Files from LOGS

---

List missing files:

robocopy `"D:\Program Files\Apache24_OLD\logs"`
"D:\Program Files\Apache24\logs" `
*.* /E /XC /XN /XO /L

Copy missing files excluding *.log:

robocopy `"D:\Program Files\Apache24_OLD\logs"`
"D:\Program Files\Apache24\logs" `
*.* /E /XC /XN /XO /XF *.log

---

12. Validate New Installation

---

Syntax check:

"D:\Program Files\Apache24\bin\httpd.exe" -t

Expected:

Syntax OK

Check virtual hosts:

"D:\Program Files\Apache24\bin\httpd.exe" -S

Check modules:

"D:\Program Files\Apache24\bin\httpd.exe" -M

Check version:

"D:\Program Files\Apache24\bin\httpd.exe" -v

---

13. Start Service

---

net start Apache24

Verify:

sc query Apache24

Expected:

STATE : RUNNING

---

14. Review Error Log

---

type "D:\Program Files\Apache24\logs\error.log"

PowerShell tail:

Get-Content `"D:\Program Files\Apache24\logs\error.log"`
-Wait

---

15. Rollback (If Needed)

---

Stop service:

net stop Apache24

Rename failed installation:

ren "D:\Program Files\Apache24" Apache24_FAILED

Restore backup:

ren "D:\Program Files\Apache24_OLD" Apache24

Start service:

net start Apache24

Verify:

sc query Apache24

---

## Recommended Order

1. Validate current installation
2. Stop Apache service
3. Rename Apache24 -> Apache24_OLD
4. Optional ZIP archive
5. Extract new Apache ZIP
6. Copy conf
7. Copy htdocs
8. Copy cgi-bin
9. Copy missing modules
10. Copy missing lib files
11. Validate configuration
12. Start service
13. Review logs
14. Keep Apache24_OLD until upgrade is confirmed
