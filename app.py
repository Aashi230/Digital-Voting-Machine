
from flask import Flask, render_template, request, jsonify
import subprocess
from pathlib import Path
import re
import threading
import atexit

app = Flask(__name__)

# --------------------------------
# PROJECT PATHS
# --------------------------------

BASE_DIR = Path(__file__).resolve().parent
SRC = BASE_DIR / "src" / "voting_machine.v"
SIM_DIR = BASE_DIR / "simulation"
TB_FILE = SIM_DIR / "live_tb.v"
OUTPUT_FILE = SIM_DIR / "live_sim"

CANDIDATES = ["A", "B", "C", "D"]

# One persistent Verilog process
simulator = None
sim_lock = threading.Lock()

latest_result = {
    "counts": {"A": 0, "B": 0, "C": 0, "D": 0},
    "winner": "No votes yet",
    "tie": False,
    "total_votes": 0
}


# --------------------------------
# RESULT PARSER
# --------------------------------

def parse_result(line):

    match = re.search(
        r"RESULT:(\d+),(\d+),(\d+),(\d+),(\d+),(\d+)",
        line
    )

    if not match:
        raise RuntimeError("Invalid Verilog result: " + line)

    a, b, c, d, winner, tie = map(int, match.groups())

    winner_names = {
        0: "No unique winner",
        1: "Candidate A",
        2: "Candidate B",
        3: "Candidate C",
        4: "Candidate D"
    }

    if tie:
        result = "Tie Detected"
    elif winner == 0:
        result = "No votes yet"
    else:
        result = winner_names[winner]

    return {
        "counts": {
            "A": a,
            "B": b,
            "C": c,
            "D": d
        },
        "winner": result,
        "tie": bool(tie),
        "total_votes": a + b + c + d
    }


# --------------------------------
# START PERSISTENT SIMULATION
# --------------------------------

def start_simulator():

    global simulator

    if simulator is not None and simulator.poll() is None:
        return

    SIM_DIR.mkdir(exist_ok=True)

    if not SRC.exists():
        raise RuntimeError("voting_machine.v not found.")

    if not TB_FILE.exists():
        raise RuntimeError("live_tb.v not found.")

    compile_result = subprocess.run(
        [
            "iverilog",
            "-o",
            str(OUTPUT_FILE),
            str(SRC),
            str(TB_FILE)
        ],
        cwd=BASE_DIR,
        capture_output=True,
        text=True,
        timeout=10
    )

    if compile_result.returncode != 0:
        raise RuntimeError(
            "Verilog compilation failed: " + compile_result.stderr
        )

    simulator = subprocess.Popen(
        ["vvp", "-i", str(OUTPUT_FILE)],
        cwd=BASE_DIR,
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        bufsize=1
    )

    # Wait until testbench is ready
    while True:

        line = simulator.stdout.readline()

        if not line:
            raise RuntimeError("Verilog simulator stopped unexpectedly.")

        if "LIVE_SIMULATION_READY" in line:
            break


# --------------------------------
# SEND COMMAND TO VERILOG
# --------------------------------

def send_command(command):

    global latest_result

    with sim_lock:

        start_simulator()

        if simulator.poll() is not None:
            raise RuntimeError("Verilog simulator is not running.")

        simulator.stdin.write(str(command) + "\n")
        simulator.stdin.flush()

        # Wait for updated result
        while True:

            line = simulator.stdout.readline()

            if not line:
                raise RuntimeError("No response from Verilog simulator.")

            if line.startswith("RESULT:"):

                latest_result = parse_result(line)
                return latest_result

            if "INPUT_CLOSED" in line:
                raise RuntimeError("Verilog input was closed.")


# --------------------------------
# CLOSE SIMULATOR WHEN SERVER EXITS
# --------------------------------

def close_simulator():

    global simulator

    if simulator is not None and simulator.poll() is None:
        simulator.terminate()


atexit.register(close_simulator)


# --------------------------------
# HOME PAGE
# --------------------------------

@app.route("/")
def home():

    return render_template("index.html")


# --------------------------------
# CAST VOTE
# --------------------------------

@app.route("/vote", methods=["POST"])
def vote():

    data = request.get_json(silent=True) or {}
    candidate = data.get("candidate")

    if candidate not in CANDIDATES:
        return jsonify({"error": "Invalid candidate"}), 400

    command = CANDIDATES.index(candidate) + 1

    try:
        result = send_command(command)
        return jsonify(result)

    except Exception as error:
        return jsonify({"error": str(error)}), 500


# --------------------------------
# SHOW RESULTS
# --------------------------------

@app.route("/results")
def results():

    with sim_lock:
        return jsonify(latest_result)


# --------------------------------
# RESET ELECTION
# --------------------------------

@app.route("/reset", methods=["POST"])
def reset():

    try:
        result = send_command(0)
        return jsonify(result)

    except Exception as error:
        return jsonify({"error": str(error)}), 500


# --------------------------------
# START SERVER
# --------------------------------

if __name__ == "__main__":

    import os

    app.run(
        host="0.0.0.0",
        port=int(os.environ.get("PORT", 5000)),
        debug=False,
        use_reloader=False
    )