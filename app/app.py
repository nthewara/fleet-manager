import os
import socket
from datetime import datetime
from flask import Flask, render_template, jsonify

app = Flask(__name__)

def get_cluster_info():
    return {
        "cluster_name": os.environ.get("CLUSTER_NAME", "unknown"),
        "environment": os.environ.get("ENVIRONMENT", "unknown"),
        "region": os.environ.get("REGION", "unknown"),
        "node_name": os.environ.get("NODE_NAME", socket.gethostname()),
        "pod_name": os.environ.get("POD_NAME", socket.gethostname()),
        "pod_ip": os.environ.get("POD_IP", "unknown"),
        "namespace": os.environ.get("POD_NAMESPACE", "default"),
        "app_version": os.environ.get("APP_VERSION", "1.0.0"),
        "k8s_version": os.environ.get("K8S_VERSION", "unknown"),
        "timestamp": datetime.utcnow().isoformat() + "Z",
    }

@app.route("/")
def index():
    info = get_cluster_info()
    return render_template("index.html", info=info)

@app.route("/api/info")
def api_info():
    return jsonify(get_cluster_info())

@app.route("/api/health")
def health():
    return jsonify({"status": "healthy", "timestamp": datetime.utcnow().isoformat() + "Z"})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
