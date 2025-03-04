from flask import Flask, request, jsonify
import subprocess
import tempfile
import os

PHPSTAN_PATH = os.path.expanduser("vendor/bin/phpstan")  # Adjust if necessary

app = Flask(__name__)
@app.route("/health", methods=["GET"])
def health_check():
    return jsonify({
        "status": "ok",
        "message": "Service is healthy and running."
    }), 200
    
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

if __name__ == "__main__":
    app.run(debug=True)
