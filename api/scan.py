from flask import Flask, request, jsonify
import subprocess
import tempfile
import os

app = Flask(__name__)

PHPSTAN_PATH = os.path.expanduser("~/.composer/vendor/bin/phpstan")  # Adjust if necessary

@app.route("/scan", methods=["POST"])
def scan_code():
    data = request.json
    php_code = data.get("code", "")

    if not php_code:
        return jsonify({"result": "No PHP code provided"}), 400

    with tempfile.NamedTemporaryFile(delete=False, suffix=".php") as tmp_file:
        tmp_file.write(php_code.encode("utf-8"))
        tmp_file_path = tmp_file.name

    try:
        result = subprocess.run(
            [PHPSTAN_PATH, "analyze", "--level=8", tmp_file_path],
            capture_output=True,
            text=True
        )
        return jsonify({"result": result.stdout or result.stderr})
    finally:
        os.unlink(tmp_file_path)  # Cleanup temp file

# This is for Vercel to handle the app
def handler(request):
    return app(request)
