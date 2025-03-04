# Exodus Backend

API endpoint to be hosted on vercel to scan PHP with PHPStan

## Test Curl Commands

Health Check
```
curl http://localhost:5000/health
```

PHP Scan
```
curl -X POST http://localhost:5000/scan \
     -H "Content-Type: application/json" \
     -d '{"code": "<?php echo 'abc'; ?>"}'

```