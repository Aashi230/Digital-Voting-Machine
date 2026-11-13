# ⚡ Digital Voting Machine

A Verilog-based Digital Electronics project that demonstrates a simple voting system using digital logic, simulation and an interactive web interface.

🌐 **Live Demo:** [Digital Voting Machine](https://digital-voting-machine-1.onrender.com/)

## 📌 About the Project

This project implements a Digital Voting Machine using Verilog HDL. It allows votes to be recorded for different candidates, maintains their vote counts and determines the winner or a tie.

The project also includes a web interface for an interactive demonstration and Verilog simulation for testing the digital logic.

## ✨ Features

- Voting for four candidates (A, B, C and D).
- Individual vote counting.
- Winner detection.
- Tie detection.
- Reset functionality.
- Verilog simulation and waveform verification.
- Interactive web interface.

## 🛠️ Technologies Used

- Verilog HDL
- Icarus Verilog
- GTKWave
- Python
- Flask
- HTML, CSS and JavaScript

## 📂 Project Structure

```text
Digital-Voting-Machine/
│
├── app.py
├── src/
│   └── voting_machine.v
├── simulation/
│   └── live_tb.v
├── testbench/
│   └── voting_machine_tb.v
├── templates/
│   └── index.html
├── static/
│   └── style.css
├── requirements.txt
├── Dockerfile
└── README.md
```

## ⚙️ How It Works

1. The system is initialized using reset.
2. A voter selects a candidate.
3. The corresponding vote input is activated.
4. The vote count is updated on the active clock edge.
5. The system compares the candidate vote counts.
6. The result displays the winner or a tie.

## 💻 Run the Project Locally


The waveform helps visualize signals such as:

- Clock and reset
- Candidate voting inputs
- Individual vote counts
- Winner and tie conditions

## 🙏 Acknowledgement

We sincerely thank our project guide **[@profprabhat7-lang](https://github.com/profprabhat7-lang)** for his guidance and support throughout this project.

## 👩‍💻 Project Details

- **Project:** Digital Voting Machine
- **Subject:** Digital Electronics
- **Domain:** Verilog HDL and Digital Logic
- **Simulation:** Icarus Verilog and GTKWave
- **Web Framework:** Flask

---

⭐ If you find this project interesting, feel free to explore it!
