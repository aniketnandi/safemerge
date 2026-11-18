**# Provided SAST scanner: SafeMerge notes**

**Start: npm start (port 3000). Health: GET /health**

**Endpoint SafeMerge uses: POST /scan/code with { "code": "..." }**

**Endpoints that read file paths (disable in the worker, S1-2): POST /scan/file, POST /scan/directory**



**Local test (S0-3): test-vulnerable.js gives 36 findings (25 HIGH, 9 MEDIUM, 2 LOW)**

**Clean code (process.env.DB\_PASSWORD) gives 0 findings**



**Notes:**

**- Findings report file as "untitled.js" when only code is sent; the worker must attach the real path**

**- Two rules can flag the same line (line 21, INSECURE\_RANDOM); dedupe by id + line**

**- Severity policy: HIGH fails safemerge/sast; MEDIUM and LOW are comments only**

