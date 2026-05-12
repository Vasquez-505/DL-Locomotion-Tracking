"""Streaming subprocess helper for Streamlit live output."""
import os
import queue
import subprocess
import threading


class StreamingSubprocess:
    """Run a subprocess and stream its stdout to a thread-safe queue.

    Usage in Streamlit:
        proc = StreamingSubprocess([sys.executable, '-u', script])
        proc.start()
        st.session_state['proc'] = proc

        # In the polling loop (call st.rerun() until proc.done):
        new_lines = proc.drain()
        st.session_state['log'].extend(new_lines)

    To stop early:
        proc.terminate()
    """

    def __init__(self, cmd, cwd=None, env=None):
        self.cmd = cmd
        self.cwd = cwd
        env_base = os.environ.copy()
        env_base["PYTHONUNBUFFERED"] = "1"
        if env:
            env_base.update(env)
        self.env = env_base
        self._q: queue.Queue = queue.Queue()
        self.done = False
        self.returncode = None
        self._thread = None
        self._proc = None   # Popen object, set once started

    def start(self):
        self._thread = threading.Thread(target=self._run, daemon=True)
        self._thread.start()

    def _run(self):
        try:
            proc = subprocess.Popen(
                self.cmd,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                bufsize=1,
                cwd=self.cwd,
                env=self.env,
            )
            self._proc = proc
            for line in proc.stdout:
                self._q.put(line.rstrip("\n"))
            proc.wait()
            self.returncode = proc.returncode
        except Exception as exc:
            self._q.put(f"[RUNNER ERROR] {exc}")
            self.returncode = -1
        finally:
            self.done = True

    def drain(self):
        """Return all pending lines without blocking."""
        lines = []
        while True:
            try:
                lines.append(self._q.get_nowait())
            except queue.Empty:
                break
        return lines

    def terminate(self):
        """Terminate the running subprocess (non-blocking)."""
        if self._proc is not None:
            try:
                self._proc.terminate()
            except Exception:
                pass
