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
        self.stub(
            "macmon",
            f"printf '%s' \"$*\" > '{self.root / 'macmon.args'}'\n"
            + "cat <<'JSON'\n"
            + json.dumps(data)
            + "\nJSON",
        )

    def linux_fixture(self, first_stat, second_stat, meminfo_text):
        self.stub("uname", "echo Linux")
        stat = self.root / "stat"
        if first_stat is not None:
            stat.write_text(first_stat)
        second = self.root / "second-stat"
        second.write_text(second_stat)
        meminfo = self.root / "meminfo"
        if meminfo_text is not None:
            meminfo.write_text(meminfo_text)
        thermal = self.root / "thermal"
        thermal.mkdir(exist_ok=True)
        self.stub("sleep", f"cp '{second}' '{stat}'")
        script = (
            SCRIPT.read_text()
            .replace("/proc/stat", str(stat))
            .replace("/proc/meminfo", str(meminfo))
            .replace("/sys/class/thermal", str(thermal))
        )
        self.script = self.root / "system-load"
        self.script.write_text(script)
        self.script.chmod(0o755)

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
        self.assertEqual(
            (self.root / "macmon.args").read_text(), "pipe --samples 1 -i 500"
        )

    def test_linux_without_temperature_sensor(self):
        self.linux_fixture(
            "cpu  10 0 10 80\n",
            "cpu  20 0 20 160\n",
            "MemTotal: 100 kB\nMemAvailable: 40 kB\n",
        )
        self.assertEqual(self.run_script(), "TEMP: -C CPU:20% RAM:60% DISK:28%")

    def test_linux_missing_available_memory(self):
        self.linux_fixture(
            "cpu  10 0 10 80\n", "cpu  20 0 20 160\n", "MemTotal: 100 kB\n"
        )
        self.assertEqual(self.run_script(), "TEMP: -C CPU:20% RAM: -% DISK:28%")

    def test_linux_malformed_available_memory(self):
        self.linux_fixture(
            "cpu  10 0 10 80\n",
            "cpu  20 0 20 160\n",
            "MemTotal: 100 kB\nMemAvailable: unknown kB\n",
        )
        self.assertEqual(self.run_script(), "TEMP: -C CPU:20% RAM: -% DISK:28%")

    def test_linux_unreadable_memory_file(self):
        self.linux_fixture("cpu  10 0 10 80\n", "cpu  20 0 20 160\n", None)
        self.assertEqual(self.run_script(), "TEMP: -C CPU:20% RAM: -% DISK:28%")

    def test_linux_partial_and_invalid_cpu_samples(self):
        memory = "MemTotal: 100 kB\nMemAvailable: 40 kB\n"
        for first, second in [
            ("cpu  10 0\n", "cpu  20 0 20 160\n"),
            ("cpu  10 0 10 80\n", "intr 20 0 20 160\n"),
            ("cpu  10 x 10 80\n", "cpu  20 0 20 160\n"),
            ("cpu  10 0 10 80\n", "cpu  20 0\n"),
            ("cpu  10 0 10 80\n", "cpu  20 x 20 160\n"),
        ]:
            with self.subTest(first=first, second=second):
                self.linux_fixture(first, second, memory)
                self.assertEqual(self.run_script(), "TEMP: -C CPU: -% RAM:60% DISK:28%")

    def test_linux_unreadable_cpu_file(self):
        self.linux_fixture(
            None, "cpu  20 0 20 160\n", "MemTotal: 100 kB\nMemAvailable: 40 kB\n"
        )
        self.assertEqual(self.run_script(), "TEMP: -C CPU: -% RAM:60% DISK:28%")

    def test_linux_zero_cpu_delta(self):
        self.linux_fixture(
            "cpu  10 0 10 80\n",
            "cpu  10 0 10 80\n",
            "MemTotal: 100 kB\nMemAvailable: 40 kB\n",
        )
        self.assertEqual(self.run_script(), "TEMP: -C CPU: -% RAM:60% DISK:28%")

    def test_linux_unavailable_and_malformed_disk(self):
        for df_body in [
            "exit 1",
            "echo 'device size used avail ??? /'",
            "echo 'header'; echo 'device 100 20 80 28 /'",
        ]:
            with self.subTest(df_body=df_body):
                self.linux_fixture(
                    "cpu  10 0 10 80\n",
                    "cpu  20 0 20 160\n",
                    "MemTotal: 100 kB\nMemAvailable: 40 kB\n",
                )
                self.stub("df", df_body)
                self.assertEqual(self.run_script(), "TEMP: -C CPU:20% RAM:60% DISK: -%")


if __name__ == "__main__":
    unittest.main()
