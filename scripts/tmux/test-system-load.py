"""Fixture checks for the tmux system-load status command."""

import json
import os
import pathlib
import shutil
import subprocess
import tempfile
import unittest

SCRIPT = pathlib.Path(__file__).with_name("system-load")


class SystemLoadTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="system-load-test-")
        self.addCleanup(self.temp.cleanup)
        self.root = pathlib.Path(self.temp.name)
        self.bin = self.root / "bin"
        self.bin.mkdir()
        (self.bin / "jq").symlink_to(shutil.which("jq"))
        self.stub("uname", "echo Darwin")
        self.stub(
            "df",
            "echo 'Filesystem 1024-blocks Used Available Capacity Mounted on'; echo '/dev/disk 100 28 72 28% /System/Volumes/Data'",
        )
        self.script = SCRIPT

    def stub(self, name, body):
        path = self.bin / name
        path.write_text("#!/bin/sh\n" + body + "\n")
        path.chmod(0o755)

    def macmon(self, data):
        self.stub("macmon", "cat <<'JSON'\n" + json.dumps(data) + "\nJSON")

    def run_script(self):
        env = os.environ.copy()
        env["PATH"] = f"{self.bin}:/usr/bin:/bin"
        result = subprocess.run(
            [str(self.script)], env=env, text=True, capture_output=True, check=True
        )
        self.assertEqual(result.stderr, "")
        return result.stdout.strip()

    def test_darwin_missing_macmon_and_failed_pmset(self):
        self.stub("pmset", "exit 1")
        self.assertEqual(self.run_script(), "TEMP: -C CPU: -% RAM: -% DISK:28% BAT:-")

    def test_darwin_failed_macmon(self):
        self.stub("macmon", "exit 1")
        self.stub("pmset", "echo 'Now drawing from AC Power'")
        self.assertEqual(self.run_script(), "TEMP: -C CPU: -% RAM: -% DISK:28%")

    def test_darwin_missing_temperature_keeps_other_metrics(self):
        self.macmon(
            {
                "temp": {},
                "pcpu_usage": [0, 0.2],
                "ecpu_usage": [0, 0.1],
                "memory": {"ram_usage": 50, "ram_total": 100},
            }
        )
        self.stub("pmset", "echo 'Now drawing from AC Power'")
        self.assertEqual(self.run_script(), "TEMP: -C CPU:30% RAM:50% DISK:28%")

    def test_darwin_charging_battery(self):
        self.macmon(
            {
                "temp": {"cpu_temp_avg": 55},
                "pcpu_usage": [0, 0.2],
                "ecpu_usage": [0, 0.1],
                "memory": {"ram_usage": 50, "ram_total": 100},
            }
        )
        self.stub(
            "pmset",
            "echo ' -InternalBattery-0 (id=123) 80%; charging; 0:20 remaining present: true'",
        )
        self.assertEqual(self.run_script(), "TEMP:55C CPU:30% RAM:50% DISK:28% BAT:80%")

    def test_linux_without_temperature_sensor(self):
        self.stub("uname", "echo Linux")
        stat = self.root / "stat"
        stat.write_text("cpu  10 0 10 80\n")
        second_stat = self.root / "second-stat"
        second_stat.write_text("cpu  20 0 20 160\n")
        meminfo = self.root / "meminfo"
        meminfo.write_text("MemTotal: 100 kB\nMemAvailable: 40 kB\n")
        thermal = self.root / "thermal"
        thermal.mkdir()
        self.stub("sleep", f"cp '{second_stat}' '{stat}'")
        script = (
            SCRIPT.read_text()
            .replace("/proc/stat", str(stat))
            .replace("/proc/meminfo", str(meminfo))
            .replace("/sys/class/thermal", str(thermal))
        )
        self.script = self.root / "system-load"
        self.script.write_text(script)
        self.script.chmod(0o755)
        self.assertEqual(self.run_script(), "TEMP: -C CPU:20% RAM:60% DISK:28%")


if __name__ == "__main__":
    unittest.main()
