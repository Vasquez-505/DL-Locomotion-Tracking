from __future__ import annotations

import re as _re

"""Utilities to extract notebook cells and build runnable Python scripts.

The GUI runs each pipeline section by:
  1. Reading the notebook JSON
  2. Finding the relevant code cells (by keyword in source)
  3. Building a standalone Python script:
       - sys.stdout.reconfigure for UTF-8
       - User FLAGS injected as top-level variables
       - Helper code extracted from the FLAGS cell (path helpers, _paths(), etc.)
       - Phase cell sources concatenated in order
  4. Writing to a temp file for subprocess execution

The temp script is run with cwd=NB_DIR so that Path().resolve() inside the
notebook code resolves to the Inference_Pipeline/ directory — exactly what
BASE_DIR does in the notebook kernel.
"""
import json
import sys
import tempfile
from pathlib import Path


# ── cell loading ──────────────────────────────────────────────────────────────

def get_cells(notebook_path: Path) -> list[dict]:
    """Return list of {'type': str, 'source': str} for every cell."""
    with open(notebook_path, encoding="utf-8") as f:
        nb = json.load(f)
    return [
        {"type": c["cell_type"], "source": "".join(c["source"])}
        for c in nb["cells"]
    ]


def find_cell(cells: list[dict], keyword: str) -> tuple[int, str]:
    """Return (index, source) of first CODE cell containing keyword."""
    for i, c in enumerate(cells):
        if c["type"] == "code" and keyword in c["source"]:
            return i, c["source"]
    raise ValueError(f"No code cell found containing {keyword!r}")


# ── FLAGS cell — extract only the helper section ──────────────────────────────

_HELPERS_MARKERS = [
    "# ── Derived paths helper",
    "# Derived paths helper",
    "from pathlib import Path",
]


def extract_helpers(flags_cell_source: str) -> str:
    """Return everything from the helper section of a FLAGS cell onwards.

    FLAGS cells start with variable assignments (VIDEO_FOLDER_NAMES_INF = ...),
    then contain a helper section that defines BASE_DIR, _paths(), etc.
    We include only the helper section because the GUI injects its own FLAG values.
    """
    for marker in _HELPERS_MARKERS:
        if marker in flags_cell_source:
            idx = flags_cell_source.index(marker)
            return flags_cell_source[idx:]
    # Fallback: include everything (safe — user FLAGS will be re-defined last)
    return flags_cell_source


# ── script builder ────────────────────────────────────────────────────────────

def _header() -> str:
    return (
        "import sys, os\n"
        "sys.stdout.reconfigure(encoding='utf-8')\n"
    )


def build_script(flags_vars: dict, helpers_src: str, cell_sources: list[str]) -> str:
    """Compose a full Python script — for Bulk Pipeline.

    User FLAGS come first so notebook helpers can reference them, but the helper
    section from the FLAGS cell (BASE_DIR, _paths, etc.) comes immediately after.

    Args:
        flags_vars:   dict of {name: value} to emit as Python assignments.
        helpers_src:  helper code extracted from the FLAGS cell (BASE_DIR, _paths, etc.)
        cell_sources: list of cell source strings to concatenate.
    """
    flag_lines = [f"{name} = {val!r}" for name, val in flags_vars.items()]
    flags_block = "\n".join(flag_lines)

    parts = [
        _header(),
        f"# ── User FLAGS ───────────────────────────────────────────────────────────────\n{flags_block}",
        f"# ── Notebook helpers ─────────────────────────────────────────────────────────\n{helpers_src}",
    ]
    for i, src in enumerate(cell_sources, 1):
        parts.append(f"# ── Cell {i} ───────────────────────────────────────────────────────────────────\n{src}")

    return "\n\n".join(parts)


def build_script_with_override(nb_flags_src: str, flags_vars: dict,
                                cell_sources: list[str]) -> str:
    """Compose a full Python script — for Active Learning.

    The notebook's FLAGS cell (which has imports + default variable assignments)
    comes first, then user FLAGS are appended to override the defaults.

    Args:
        nb_flags_src: complete source of the notebook's FLAGS cell (cell 1).
        flags_vars:   dict of {name: value} — user's overrides.
        cell_sources: list of subsequent cell source strings.
    """
    flag_lines = [f"{name} = {val!r}" for name, val in flags_vars.items()]
    flags_block = "\n".join(flag_lines)

    parts = [
        _header(),
        f"# ── Notebook FLAGS cell (provides imports + defaults) ────────────────────────\n{nb_flags_src}",
        f"# ── GUI override (replaces defaults above) ──────────────────────────────────\n{flags_block}",
    ]
    for i, src in enumerate(cell_sources, 1):
        parts.append(f"# ── Cell {i} ───────────────────────────────────────────────────────────────────\n{src}")

    return "\n\n".join(parts)


def write_temp_script(content: str) -> Path:
    """Write script to a temp .py file and return its path."""
    with tempfile.NamedTemporaryFile(
        mode="w", suffix=".py", delete=False, encoding="utf-8"
    ) as f:
        f.write(content)
        return Path(f.name)


# ── Bulk Pipeline script builders ─────────────────────────────────────────────

def bulk_section1_script(nb_path: Path, flags: dict) -> Path:
    """Phases 1–3: BG subtraction → videos → inference."""
    cells = get_cells(nb_path)
    _, flags_src = find_cell(cells, "FLAGS A")
    _, ph1_src   = find_cell(cells, "# Phase 1 --")
    _, ph2_src   = find_cell(cells, "# Phase 2 --")
    _, ph3_src   = find_cell(cells, "# Phase 3 --")
    helpers = extract_helpers(flags_src)
    script = build_script(flags, helpers, [ph1_src, ph2_src, ph3_src])
    return write_temp_script(script)


def bulk_phase4_script(nb_path: Path, flags_a: dict, video_names_ana: list) -> Path:
    """Phase 4: open SLEAP GUIs."""
    cells = get_cells(nb_path)
    _, flags_src = find_cell(cells, "FLAGS A")
    _, ph4_src   = find_cell(cells, "# Phase 4 --")
    helpers = extract_helpers(flags_src)
    merged_flags = {**flags_a, "VIDEO_FOLDER_NAMES_ANA": video_names_ana}
    script = build_script(merged_flags, helpers, [ph4_src])
    return write_temp_script(script)


def _strip_var_block(src: str, var_name: str) -> str:
    """Remove the first `var_name = {…}` block from src (any nesting depth)."""
    lines = src.splitlines(keepends=True)
    result = []
    in_block = False
    depth = 0
    for line in lines:
        if not in_block and line.lstrip().startswith(f"{var_name} = "):
            in_block = True
            depth = line.count("{") - line.count("}")
            if depth <= 0:
                in_block = False   # single-line dict
            continue
        if in_block:
            depth += line.count("{") - line.count("}")
            if depth <= 0:
                in_block = False
            continue
        result.append(line)
    return "".join(result)


def bulk_trim_script(nb_path: Path, flags_a: dict, trim_frames: dict = None) -> Path:
    """Phase 4.4: trim to a frame interval [TRIM_START, TRIM_END].

    ``trim_frames`` is accepted for backward compatibility but ignored — the GUI
    now passes ``TRIM_START`` and ``TRIM_END`` dicts via ``flags_a``.
    """
    cells = get_cells(nb_path)
    _, flags_src  = find_cell(cells, "FLAGS A")
    # Locate the trim cell by its TRIM_END marker (unique to that cell)
    _, trim_src   = find_cell(cells, "TRIM_END = {")
    # Strip the notebook's hardcoded TRIM_START / TRIM_END blocks — GUI injects them
    trim_src = _strip_var_block(trim_src, "TRIM_START")
    trim_src = _strip_var_block(trim_src, "TRIM_END")
    helpers = extract_helpers(flags_src)
    trim_start = flags_a.get("TRIM_START", {}) if isinstance(flags_a, dict) else {}
    trim_end   = flags_a.get("TRIM_END",   {}) if isinstance(flags_a, dict) else {}
    merged_flags = {**flags_a, "TRIM_START": trim_start, "TRIM_END": trim_end}
    script = build_script(merged_flags, helpers, [trim_src])
    return write_temp_script(script)


def bulk_preflight_script(nb_path: Path, flags_a: dict, video_names_ana: list) -> Path:
    """Phase 6: pre-flight validation."""
    cells = get_cells(nb_path)
    _, flags_src = find_cell(cells, "FLAGS A")
    _, pf_src    = find_cell(cells, "# Phase 6 --")
    helpers = extract_helpers(flags_src)
    merged_flags = {**flags_a, "VIDEO_FOLDER_NAMES_ANA": video_names_ana}
    script = build_script(merged_flags, helpers, [pf_src])
    return write_temp_script(script)


def bulk_section3_script(nb_path: Path, flags_a: dict, video_names_ana: list) -> Path:
    """Phases 7–10: export labels → extract tracks → TRACKS.mat → FlyWalker."""
    cells = get_cells(nb_path)
    _, flags_src = find_cell(cells, "FLAGS A")
    _, ph7_src   = find_cell(cells, "# Phase 7 --")
    _, ph8_src   = find_cell(cells, "# Phase 8 --")
    _, ph9_src   = find_cell(cells, "# Phase 9 --")
    _, ph10_src  = find_cell(cells, "# Phase 10 --")
    helpers = extract_helpers(flags_src)
    merged_flags = {**flags_a, "VIDEO_FOLDER_NAMES_ANA": video_names_ana}
    script = build_script(merged_flags, helpers, [ph7_src, ph8_src, ph9_src, ph10_src])
    return write_temp_script(script)


# Keep old name as alias for backward compatibility
def bulk_section2_script(nb_path: Path, flags_a: dict, video_names_ana: list) -> Path:
    return bulk_section3_script(nb_path, flags_a, video_names_ana)


# ── Active Learning script builders ───────────────────────────────────────────

def _al_nb_flags(nb_path: Path) -> tuple[str, list[dict]]:
    """Return (notebook_flags_cell_src, cells) for the Active Learning notebook."""
    cells = get_cells(nb_path)
    _, flags_src = find_cell(cells, "NEW_VIDEOS")
    return flags_src, cells


def al_step1_script(nb_path: Path, flags: dict) -> Path:
    """Step 1: verify corrected labels."""
    nb_flags, cells = _al_nb_flags(nb_path)
    _, s1 = find_cell(cells, "Auto-patch")
    script = build_script_with_override(nb_flags, flags, [s1])
    return write_temp_script(script)


def al_step2_script(nb_path: Path, flags: dict) -> Path:
    """Step 2: merge datasets + embed frames into .pkg.slp."""
    nb_flags, cells = _al_nb_flags(nb_path)
    _, s1 = find_cell(cells, "Auto-patch")
    _, s2 = find_cell(cells, "MERGED_SLP")
    script = build_script_with_override(nb_flags, flags, [s1, s2])
    return write_temp_script(script)


def al_step3_script(nb_path: Path, flags: dict, run_name: str) -> Path:
    """Step 3: build fine-tune config YAML.

    Steps 1 & 2 outputs are loaded from .al_run_state.json by the target cell
    itself — no need to re-execute them here.
    """
    nb_flags, cells = _al_nb_flags(nb_path)
    _, s3 = find_cell(cells, "single_instance_ft")
    merged = {**flags, "RUN_NAME": run_name}
    script = build_script_with_override(nb_flags, merged, [s3])
    return write_temp_script(script)


def al_step35_script(nb_path: Path, flags: dict, run_name: str) -> Path:
    """Step 3.5: hardware check (standalone — no notebook steps needed before it)."""
    nb_flags, cells = _al_nb_flags(nb_path)
    _, s35 = find_cell(cells, "platform.processor")
    merged = {**flags, "RUN_NAME": run_name}
    script = build_script_with_override(nb_flags, merged, [s35])
    return write_temp_script(script)


def al_step4_script(nb_path: Path, flags: dict, run_name: str) -> Path:
    """Step 4: train locally or prepare Colab zip.

    Steps 1, 2, 3 outputs are loaded from .al_run_state.json by the target cell
    itself — no need to re-execute them here.
    """
    nb_flags, cells = _al_nb_flags(nb_path)
    _, s4 = find_cell(cells, "sleap_nn.cli")
    merged = {**flags, "RUN_NAME": run_name}
    script = build_script_with_override(nb_flags, merged, [s4])
    return write_temp_script(script)


def al_step5_script(nb_path: Path, flags: dict, run_name: str) -> Path:
    """Step 5: evaluate & compare results.

    Steps 1, 2, 3 outputs are loaded from .al_run_state.json by the target cell
    itself — no need to re-execute them here.
    """
    nb_flags, cells = _al_nb_flags(nb_path)
    _, s5 = find_cell(cells, "eval_model")
    merged = {**flags, "RUN_NAME": run_name}
    script = build_script_with_override(nb_flags, merged, [s5])
    return write_temp_script(script)


_IPYTHON_SHIM = (
    "try:\n"
    "    from IPython.display import Image, display\n"
    "except ImportError:\n"
    "    def display(*args, **kwargs): pass\n"
    "    class Image:\n"
    "        def __init__(self, *args, **kwargs): pass\n"
)

_IPYTHON_RE = None


def _patch_ipython(src: str) -> str:
    """Replace ALL IPython.display imports with a try/except shim (first) or alias."""
    global _IPYTHON_RE
    if _IPYTHON_RE is None:
        import re
        _IPYTHON_RE = re.compile(r"from IPython\.display import ([^\n]+)")
    first = True

    def _replace(m):
        nonlocal first
        imports_str = m.group(1)
        if first:
            first = False
            return _IPYTHON_SHIM.rstrip()
        # Subsequent imports: resolve any `as ALIAS` forms so callers don't break.
        import re as _re
        aliases = []
        for part in imports_str.split(","):
            part = part.strip()
            am = _re.match(r"(\w+)\s+as\s+(\w+)", part)
            if am:
                aliases.append(f"{am.group(2)} = {am.group(1)}")
        return "\n".join(aliases) if aliases else "# (IPython.display already shimmed above)"

    return _IPYTHON_RE.sub(_replace, src)


def _strip_comparison(src: str) -> str:
    """Remove the fine-tuned-vs-base comparison section for standalone eval.

    Keeps everything up to section 5 (COMPARISON) and then jumps to the
    SUMMARY block at the end.
    """
    start_marker   = "# ── 5. COMPARISON"
    summary_marker = "# ── 7. SUMMARY"
    if start_marker not in src:
        return src
    before = src[:src.index(start_marker)]
    after  = src[src.index(summary_marker):] if summary_marker in src else ""
    return before + after


# ── Prediction pre-step — generates missing labels_pr/gt/metrics files ────────

_PREDICTION_PRE_STEP = '''
import subprocess as _evsubp, shutil as _evshutil

# ── Locate a Python interpreter that has sleap_nn installed ──────────────────
def _ev_has_sleap_nn(py):
    try:
        r = _evsubp.run([str(py), '-c', 'import sleap_nn'],
                        capture_output=True, timeout=15)
        return r.returncode == 0
    except Exception:
        return False

def _ev_find_sleap_py():
    try:
        import sleap_nn as _m
        _cand = Path(_m.__file__).parents[3] / 'python.exe'
        if _cand.exists() and _ev_has_sleap_nn(_cand):
            return _cand
    except ImportError:
        pass
    for _base in (Path.home() / 'anaconda3', Path.home() / 'miniconda3',
                  Path('C:/ProgramData/anaconda3'), Path('C:/ProgramData/miniconda3')):
        _py = _base / 'python.exe'
        if _py.exists() and _ev_has_sleap_nn(_py):
            return _py
        _ed = _base / 'envs'
        if _ed.exists():
            for _d in sorted(_ed.iterdir()):
                _py = _d / 'python.exe'
                if _py.exists() and _ev_has_sleap_nn(_py):
                    return _py
    return None

# ── Reconstruct training_config.yaml from best.ckpt if it is missing ─────────
def _ev_reconstruct_config(model_dir):
    """Find a sibling model with identical architecture and copy its config."""
    cfg_path = model_dir / 'training_config.yaml'
    if cfg_path.exists():
        return True

    ckpt_path = model_dir / 'best.ckpt'
    if not ckpt_path.exists():
        return False

    try:
        import torch as _torch, yaml as _yaml
    except ImportError:
        return False

    try:
        _ckpt = _torch.load(str(ckpt_path), map_location='cpu', weights_only=False)
        _target_keys = set(_ckpt['state_dict'].keys())
    except Exception as _e:
        print(f"  Could not read checkpoint: {_e}")
        return False

    print("  Searching for matching architecture in sibling models …", flush=True)
    for _cand_dir in sorted(model_dir.parent.iterdir()):
        if _cand_dir == model_dir or not _cand_dir.is_dir():
            continue
        _cand_cfg  = _cand_dir / 'training_config.yaml'
        _cand_ckpt = _cand_dir / 'best.ckpt'
        if not _cand_cfg.exists() or not _cand_ckpt.exists():
            continue
        try:
            _cc = _torch.load(str(_cand_ckpt), map_location='cpu', weights_only=False)
            if set(_cc['state_dict'].keys()) != _target_keys:
                continue
            # Same architecture — copy config, update run identifiers only
            with open(_cand_cfg, encoding='utf-8') as _f:
                _cfg = _yaml.safe_load(_f)
            _mname = model_dir.name
            _cfg['name'] = _mname
            if isinstance(_cfg.get('trainer_config'), dict):
                _cfg['trainer_config']['run_name'] = _mname
                if isinstance(_cfg['trainer_config'].get('wandb'), dict):
                    _cfg['trainer_config']['wandb']['name'] = _mname
            with open(cfg_path, 'w', encoding='utf-8') as _f:
                _yaml.dump(_cfg, _f, default_flow_style=False, allow_unicode=True)
            print(f"  Reconstructed training_config.yaml from {_cand_dir.name}")
            return True
        except Exception:
            continue

    print("  No matching architecture found among sibling models.")
    print("  Attempting to reconstruct config from checkpoint weight shapes …", flush=True)

    # ── Fallback: build config from weight shapes ─────────────────────────────
    try:
        _sd   = _ckpt['state_dict']
        _keys = set(_sd.keys())

        # Detect backbone from key patterns
        _is_swint    = any('relative_position_bias_table' in k for k in _keys)
        _is_convnext = any('layer_scale' in k for k in _keys)
        _is_unet     = any('unet' in k.lower() for k in _keys)

        # Detect in_channels + embed_dim from patch embedding weight
        _pe_key = next((k for k in _keys if 'features.0.0.weight' in k or
                        'stem.0.weight' in k or 'patch_embed' in k and 'weight' in k), None)
        _embed_dim, _in_ch = 96, 3
        if _pe_key:
            _shape = _sd[_pe_key].shape  # (out_ch, in_ch, kH, kW)
            _embed_dim, _in_ch = int(_shape[0]), int(_shape[1])

        # Detect num_keypoints from confmap head weight
        _head_key = next((k for k in _keys if 'ConfmapsHead' in k and 'weight' in k and
                          len(_sd[k].shape) == 4), None)
        _num_kp = int(_sd[_head_key].shape[0]) if _head_key else 9

        _PART_NAMES_9 = ['head1','thorax1','abdomen1',
                         'forelegR1','forelegL1','midlegR1','midlegL1','hindlegR1','hindlegL1']
        _part_names = _PART_NAMES_9 if _num_kp == 9 else [f'kp{i}' for i in range(_num_kp)]

        # Skeleton edges (standard drosophila single-instance)
        _edges = [{'source':{'name':'thorax1'},'destination':{'name':n}}
                  for n in ['head1','abdomen1','forelegR1','forelegL1',
                            'midlegR1','midlegL1','hindlegR1','hindlegL1']]

        _backbone_cfg = {'unet': None, 'convnext': None, 'swint': None}
        if _is_swint:
            _swint_type = {96:'tiny', 128:'small', 192:'base'}.get(_embed_dim, 'tiny')
            _backbone_cfg['swint'] = {
                'pre_trained_weights': None,
                'model_type': _swint_type,
                'arch': None,
                'max_stride': 32,
                'patch_size': 4,
                'stem_patch_stride': 2,
                'window_size': 7,
                'in_channels': _in_ch,
                'kernel_size': 3,
                'filters_rate': 2,
                'convs_per_block': 2,
                'up_interpolate': True,
                'output_stride': 4,
            }
        elif _is_convnext:
            _backbone_cfg['convnext'] = {
                'model_type': 'tiny', 'arch': None,
                'stem_patch_kernel': 4, 'stem_patch_stride': 2,
                'in_channels': _in_ch, 'kernel_size': 3,
                'filters_rate': 2.0, 'convs_per_block': 2,
                'up_interpolate': True, 'output_stride': 4, 'max_stride': 32,
                'pre_trained_weights': None,
            }
        else:
            print("  Unknown backbone — cannot reconstruct config.")
            print("  Download the complete model folder from Google Drive/Colab.")
            return False

        _mname = model_dir.name
        _cfg = {
            'name': _mname,
            'description': '',
            'sleap_nn_version': '0.1.3',
            'filename': '',
            'data_config': {
                'train_labels_path': [None], 'val_labels_path': [None],
                'validation_fraction': 0.0, 'use_same_data_for_val': False,
                'test_file_path': None, 'provider': 'LabelsReader',
                'user_instances_only': True, 'data_pipeline_fw': 'torch_dataset',
                'cache_img_path': None, 'use_existing_imgs': False,
                'delete_cache_imgs_after_training': True,
                'parallel_caching': True, 'cache_workers': 0,
                'preprocessing': {
                    'ensure_rgb': (_in_ch == 3), 'ensure_grayscale': (_in_ch == 1),
                    'max_height': 138, 'max_width': 468, 'scale': 1.0,
                    'crop_size': None, 'min_crop_size': 100, 'crop_padding': None,
                },
                'use_augmentations_train': True,
                'skeletons': [{'nodes': [{'name': n} for n in _part_names],
                               'edges': _edges, 'name': 'Skeleton-0'}],
            },
            'model_config': {
                'init_weights': 'default',
                'pretrained_backbone_weights': None, 'pretrained_head_weights': None,
                'backbone_config': _backbone_cfg,
                'head_configs': {
                    'single_instance': {'confmaps': {
                        'part_names': _part_names, 'sigma': 2.5, 'output_stride': 4,
                    }},
                    'centroid': None, 'centered_instance': None,
                    'bottomup': None, 'multi_class_bottomup': None, 'multi_class_topdown': None,
                },
            },
            'trainer_config': {
                'train_data_loader': {'batch_size': 6, 'num_workers': 2, 'shuffle': True},
                'val_data_loader':   {'batch_size': 6, 'num_workers': 2, 'shuffle': False},
                'model_ckpt': {'save_top_k': 1, 'save_last': True},
                'trainer_devices': 1, 'trainer_device_indices': None,
                'trainer_accelerator': 'gpu', 'profiler': None,
                'trainer_strategy': 'auto', 'enable_progress_bar': True,
                'min_train_steps_per_epoch': 200, 'train_steps_per_epoch': 200,
                'visualize_preds_during_training': False, 'keep_viz': False,
                'max_epochs': 200, 'seed': 42,
                'use_wandb': False, 'save_ckpt': True,
                'ckpt_dir': None, 'run_name': _mname, 'resume_ckpt_path': None,
                'wandb': {
                    'entity': None, 'project': None, 'name': _mname,
                    'save_viz_imgs_wandb': False, 'api_key': None, 'wandb_mode': None,
                    'prv_runid': None, 'group': None, 'current_run_id': None,
                    'viz_enabled': True, 'viz_boxes': False, 'viz_masks': False,
                    'viz_box_size': 5.0, 'viz_confmap_threshold': 0.1,
                    'log_viz_table': False, 'delete_local_logs': None,
                },
                'optimizer_name': 'Adam',
                'optimizer': {'lr': 0.0001, 'amsgrad': True},
                'lr_scheduler': {
                    'step_lr': None,
                    'reduce_lr_on_plateau': {
                        'threshold': 1e-6, 'threshold_mode': 'rel',
                        'cooldown': 3, 'patience': 20, 'factor': 0.5, 'min_lr': 1e-6,
                    },
                    'cosine_annealing_warmup': None,
                    'linear_warmup_linear_decay': None,
                },
                'early_stopping': {'min_delta': 1e-8, 'patience': 20, 'stop_training_on_plateau': True},
                'online_hard_keypoint_mining': {
                    'online_mining': False, 'hard_to_easy_ratio': 2.0,
                    'min_hard_keypoints': 2, 'max_hard_keypoints': None, 'loss_scale': 5.0,
                },
                'zmq': {'controller_port': None, 'controller_polling_timeout': 10, 'publish_port': None},
                'eval': {
                    'enabled': False, 'frequency': 1, 'oks_stddev': 0.025,
                    'oks_scale': None, 'match_threshold': 50.0,
                },
            },
        }

        with open(cfg_path, 'w', encoding='utf-8') as _f:
            _yaml.dump(_cfg, _f, default_flow_style=False, allow_unicode=True)
        _arch_name = 'SwinT-tiny' if _is_swint else 'ConvNeXt-tiny'
        print(f"  Reconstructed training_config.yaml from weight shapes ({_arch_name}, {_in_ch}ch, {_num_kp} kp)")
        return True

    except Exception as _be:
        print(f"  Weight-based reconstruction failed: {_be}")
        print("  Download the complete model folder from Google Drive/Colab.")
        return False

# ── Generate predictions + SLEAP metrics for one split if not yet present ────
def _ev_ensure_split(sleap_py, model_dir, gt_slp, split):
    pr_path  = model_dir / f'labels_pr.{split}.0.slp'
    gt_dest  = model_dir / f'labels_gt.{split}.0.slp'
    npz_path = model_dir / f'metrics.{split}.0.npz'

    if not Path(gt_slp).exists():
        print(f"  [{split.upper()}] Ground-truth file not found: {gt_slp} — skipping.")
        return

    # Verify training_config.yaml exists (upfront reconstruction already attempted)
    _has_cfg = ((model_dir / 'training_config.yaml').exists() or
                (model_dir / 'training_config.json').exists())
    if not _has_cfg:
        print(f"  [{split.upper()}] Skipping — training_config.yaml could not be reconstructed.")
        return

    # Ensure labels_gt copy exists in model folder (required by eval command)
    if not gt_dest.exists():
        _evshutil.copy(str(gt_slp), str(gt_dest))
        print(f"  [{split.upper()}] GT labels copied → {gt_dest.name}")

    # Run inference if predictions are missing
    if not pr_path.exists():
        if sleap_py is None:
            print(f"  [{split.upper()}] sleap_nn not found — cannot auto-generate predictions.")
            print( "             Install sleap-nn or run training to completion.")
            return
        print(f"  [{split.upper()}] Running inference (sleap_nn track) …", flush=True)
        _r = _evsubp.run(
            [str(sleap_py), '-m', 'sleap_nn.cli', 'track',
             '--data_path',   str(gt_slp),
             '--model_paths', str(model_dir),
             '--output_path', str(pr_path),
             '--device',      'cpu'],
            capture_output=True, text=True,
        )
        if _r.returncode != 0:
            print(f"  [{split.upper()}] Inference failed:\\n{_r.stderr[-800:]}")
            return
        print(f"  [{split.upper()}] Predictions saved  → {pr_path.name}")

    # Compute SLEAP built-in metrics if not yet saved
    if not npz_path.exists() and pr_path.exists():
        _gt_for_eval = str(gt_dest if gt_dest.exists() else gt_slp)
        _eval_py = str(sleap_py or _ev_find_sleap_py() or sys.executable)

        # ── Attempt 1: sleap_nn.cli eval ──────────────────────────────────────
        _r = _evsubp.run(
            [_eval_py, '-m', 'sleap_nn.cli', 'eval',
             '--ground_truth_path', _gt_for_eval,
             '--predicted_path',    str(pr_path),
             '--save_metrics',      str(npz_path)],
            capture_output=True, text=True,
        )
        if _r.returncode == 0:
            print(f"  [{split.upper()}] SLEAP metrics saved → {npz_path.name}")
        else:
            # ── Attempt 2: pure-Python metrics from raw SLP files ─────────────
            # sleap_nn.cli eval fails with "Empty Frame Pairs" when the video
            # object references differ between GT and PR files (known bug in
            # sleap_nn 0.1.3).  Compute OKS / mAP / mAR / PCK / visibility
            # ourselves from the raw coordinates via sleap_io.
            print(f"  [{split.upper()}] CLI eval failed — computing metrics in Python …", flush=True)
            try:
                import sleap_io as _sio, numpy as _np

                _lgt = _sio.load_slp(_gt_for_eval)
                _lpr = _sio.load_slp(str(pr_path))

                _gt_map = {lf.frame_idx: lf for lf in _lgt if lf.instances}
                _pr_map = {lf.frame_idx: lf for lf in _lpr if lf.instances}
                _common = sorted(set(_gt_map) & set(_pr_map))

                def _pts(inst):
                    try:    return inst.numpy().astype(float)
                    except: return _np.array([[p.x, p.y] for p in inst.points], dtype=float)

                _dists, _oks_frames = [], []
                _vtp = _vfp = _vfn = 0
                _OKS_STD = 0.025  # SLEAP default

                for _fi in _common:
                    _gp = _pts(_gt_map[_fi].instances[0])
                    _pp = _pts(_pr_map[_fi].instances[0])
                    _gv = ~_np.isnan(_gp[:, 0])
                    _pv = ~_np.isnan(_pp[:, 0])
                    _n  = min(len(_gp), len(_pp))

                    _vis_pts = _gp[_gv]
                    _area = max(
                        ((_vis_pts[:, 0].max() - _vis_pts[:, 0].min()) *
                         (_vis_pts[:, 1].max() - _vis_pts[:, 1].min())) if len(_vis_pts) >= 2 else 1.0,
                        1.0
                    )
                    _oks_k = []
                    for _k in range(_n):
                        _gvk, _pvk = bool(_gv[_k]), bool(_pv[_k])
                        if _gvk and _pvk:
                            _d = float(_np.hypot(_pp[_k,0]-_gp[_k,0], _pp[_k,1]-_gp[_k,1]))
                            _dists.append(_d)
                            _vtp += 1
                        elif not _gvk and _pvk: _vfp += 1
                        elif _gvk and not _pvk: _vfn += 1
                        if _gvk:
                            _d2 = (float((_pp[_k,0]-_gp[_k,0])**2 + (_pp[_k,1]-_gp[_k,1])**2)
                                   if _pvk else float('inf'))
                            _oks_k.append(float(_np.exp(-_d2 / (2*_area*_OKS_STD**2))) if _pvk else 0.0)
                    if _oks_k:
                        _oks_frames.append(float(_np.mean(_oks_k)))

                _da  = _np.array(_dists)       if _dists       else _np.array([_np.nan])
                _oa  = _np.array(_oks_frames)  if _oks_frames  else _np.array([_np.nan])
                _mOKS = float(_np.nanmean(_oa))

                _thrs = _np.arange(0.5, 1.0, 0.05)
                _n_gt = len(_common)
                _aps  = [int(_np.sum(_oa >= _t)) / max(len(_oa), 1) for _t in _thrs]
                _ars  = [int(_np.sum(_oa >= _t)) / max(_n_gt,    1) for _t in _thrs]

                _tot_pred = _vtp + _vfp
                _tot_gt   = _vtp + _vfn
                _pck5 = float(_np.sum(_da <= 5.0) / len(_da)) if len(_da) else float('nan')

                _metrics_dict = {
                    'mOKS': {'mOKS': _mOKS},
                    'voc_metrics': {
                        'oks_voc.mAP': float(_np.mean(_aps)),
                        'oks_voc.mAR': float(_np.mean(_ars)),
                    },
                    'distance_metrics': {
                        'avg': [float(_np.nanmean(_da))],
                        'p50': [float(_np.nanpercentile(_da, 50))],
                        'p90': [float(_np.nanpercentile(_da, 90))],
                        'p95': [float(_np.nanpercentile(_da, 95))],
                        'p99': [float(_np.nanpercentile(_da, 99))],
                    },
                    'pck_metrics': {'mPCK': _pck5, 'PCK@5': _pck5},
                    'visibility_metrics': {
                        'precision': float(_vtp/_tot_pred) if _tot_pred else float('nan'),
                        'recall':    float(_vtp/_tot_gt)   if _tot_gt   else float('nan'),
                        'fp': int(_vfp), 'fn': int(_vfn),
                    },
                }
                _np.savez(str(npz_path), metrics=_metrics_dict)
                print(f"  [{split.upper()}] SLEAP metrics saved (Python fallback, {len(_common)} frames) → {npz_path.name}")
            except Exception as _pe:
                print(f"  [{split.upper()}] Python metrics fallback failed: {_pe}")
                print(f"  [{split.upper()}] Will retry on next regeneration.")

# ── Determine which splits need work (missing predictions OR missing/empty metrics) ──
def _ev_needs_work(s):
    pr  = NEW_MODEL_DIR / f'labels_pr.{s}.0.slp'
    npz = NEW_MODEL_DIR / f'metrics.{s}.0.npz'
    if not pr.exists():
        return True
    if not npz.exists():
        return True
    # Treat empty npz (old failure sentinel) as missing — always retry
    try:
        import numpy as _np_chk
        _d = _np_chk.load(str(npz), allow_pickle=True)
        if len(_d.files) == 0:
            return True
    except Exception:
        return True  # corrupt file — retry
    return False

_ev_missing = [s for s in ('train', 'val', 'test') if _ev_needs_work(s)]

if _ev_missing:
    _ev_missing_pr  = [s for s in _ev_missing if not (NEW_MODEL_DIR / f'labels_pr.{s}.0.slp').exists()]
    _ev_missing_npz = [s for s in _ev_missing if not (NEW_MODEL_DIR / f'metrics.{s}.0.npz').exists()
                       and s not in _ev_missing_pr]
    if _ev_missing_pr:
        print(f"Missing prediction files for: {', '.join(s.upper() for s in _ev_missing_pr)}")
    if _ev_missing_npz:
        print(f"Missing SLEAP metrics for   : {', '.join(s.upper() for s in _ev_missing_npz)}")
    if 'train' in _ev_missing_pr:
        print("  NOTE: TRAIN inference covers 755 frames — may take several minutes on CPU.")

    # Reconstruct training_config.yaml once upfront (avoids redundant scans per split)
    _has_cfg = ((NEW_MODEL_DIR / 'training_config.yaml').exists() or
                (NEW_MODEL_DIR / 'training_config.json').exists())
    if not _has_cfg:
        print("training_config.yaml not found — attempting reconstruction …", flush=True)
        _ev_reconstruct_config(NEW_MODEL_DIR)
        print()

    print("Searching for sleap_nn Python environment …", flush=True)
    _ev_sleap_py = _ev_find_sleap_py()
    print(f"  Found: {_ev_sleap_py}" if _ev_sleap_py else "  WARNING: sleap_nn not found.")
    print()

    ORIG_TRAIN_SLP = DATASET_DIR / ORIG_TRAIN_SLP_NAME
    ORIG_VAL_SLP   = DATASET_DIR / ORIG_VAL_SLP_NAME

    _ev_gt_map = {
        'train': ORIG_TRAIN_SLP,
        'val':   ORIG_VAL_SLP,
        'test':  ORIG_TEST_SLP,
    }
    for _ev_split in _ev_missing:
        _ev_ensure_split(_ev_sleap_py, NEW_MODEL_DIR, _ev_gt_map[_ev_split], _ev_split)
    print()
else:
    _ev_sleap_py = None   # not needed — all files present
'''


# ── Metrics export step — saves sm/cm results to CSV for GUI display ──────────

_METRICS_EXPORT_STEP = '''
import pandas as _pd, numpy as _np

_rows = []
for _split in ('val', 'test', 'train'):
    _ms     = sm.get(_split, {})
    _cm_res = cm.get(_split)
    _row = {'Split': _split.upper()}
    for _k, _lbl in [
        ('mOKS',          'mOKS'),
        ('mAP',           'mAP'),
        ('mAR',           'mAR'),
        ('dist_avg',      'Avg dist (px)'),
        ('dist_p50',      'p50 dist (px)'),
        ('dist_p90',      'p90 dist (px)'),
        ('mPCK',          'mPCK'),
        ('PCK@5px',       'PCK@5px'),
        ('vis_precision', 'Vis Precision'),
        ('vis_recall',    'Vis Recall'),
    ]:
        _v = _ms.get(_k, float('nan'))
        _row[_lbl] = round(float(_v), 4) if _v == _v else float('nan')
    if _cm_res:
        _row['MPE (px)']     = round(float(_np.nanmean(_cm_res['mpe'])),    3)
        _row['FP rate (%)']  = round(float(_cm_res['global_fp'] * 100),     2)
        _row['FN rate (%)']  = round(float(_cm_res['global_fn'] * 100),     2)
        _row['TD (px/fr)']   = round(float(_np.nanmean(_cm_res['td'])),     3)
        _row['CR_frame (%)'] = round(float(_cm_res['cr_frame']),            1)
        _row['CR_kp (%)']    = round(float(_np.nanmean(_cm_res['cr_kp'])),  1)
    else:
        for _col in ['MPE (px)', 'FP rate (%)', 'FN rate (%)', 'TD (px/fr)', 'CR_frame (%)', 'CR_kp (%)']:
            _row[_col] = float('nan')
    _rows.append(_row)

_df_metrics = _pd.DataFrame(_rows)
_df_metrics.to_csv(NEW_MODEL_DIR / 'eval_metrics_summary.csv', index=False)
print(f"Metrics table saved → eval_metrics_summary.csv")
'''


def al_eval_only_script(nb_path: Path, flags: dict, model_name: str) -> Path:
    """Standalone evaluation for any model — metrics + plots, no comparison.

    Auto-generates missing prediction files (labels_pr/gt/metrics) via
    sleap_nn CLI if needed, then runs the eval cell without the comparison
    section.  RUN_NAME is overridden to the selected model.
    """
    nb_flags, cells = _al_nb_flags(nb_path)
    _, s_eval = find_cell(cells, "eval_model")
    nb_flags = _patch_ipython(nb_flags)
    s_eval   = _patch_ipython(_strip_comparison(s_eval))
    merged = {**flags, "RUN_NAME": model_name}
    _derived = (
        "BASE_DIR       = Path().resolve()\n"
        "DATASET_DIR    = BASE_DIR / 'SLEAP_Dataset'\n"
        "MODELS_DIR     = BASE_DIR / 'Models' / 'SLEAP_Models'\n"
        "BASE_MODEL_DIR = MODELS_DIR / BASE_MODEL_NAME\n"
        "ORIG_TEST_SLP  = DATASET_DIR / ORIG_TEST_SLP_NAME\n"
        "NEW_MODEL_DIR  = MODELS_DIR / RUN_NAME\n"
    )
    script = build_script_with_override(
        nb_flags, merged,
        [_derived, _PREDICTION_PRE_STEP, s_eval, _METRICS_EXPORT_STEP],
    )
    return write_temp_script(script)


def al_full_eval_script(nb_path: Path, flags: dict, model_name: str) -> Path:
    """Full evaluation for any model with best.ckpt.

    Generates missing labels_pr/gt/metrics files via sleap_nn CLI if needed,
    then runs the complete eval cell (custom metrics, per-keypoint plots,
    comparison vs base model for both VAL and TEST sets).
    """
    nb_flags, cells = _al_nb_flags(nb_path)
    _, s_eval = find_cell(cells, "eval_model")
    nb_flags = _patch_ipython(nb_flags)
    # Keep full eval including comparison section (no _strip_comparison)
    s_eval   = _patch_ipython(s_eval)
    merged = {**flags, "RUN_NAME": model_name}
    _derived = (
        "BASE_DIR       = Path().resolve()\n"
        "DATASET_DIR    = BASE_DIR / 'SLEAP_Dataset'\n"
        "MODELS_DIR     = BASE_DIR / 'Models' / 'SLEAP_Models'\n"
        "BASE_MODEL_DIR = MODELS_DIR / BASE_MODEL_NAME\n"
        "ORIG_TEST_SLP  = DATASET_DIR / ORIG_TEST_SLP_NAME\n"
        "NEW_MODEL_DIR  = MODELS_DIR / RUN_NAME\n"
    )
    script = build_script_with_override(
        nb_flags, merged,
        [_derived, _PREDICTION_PRE_STEP, s_eval],
    )
    return write_temp_script(script)


# ── SLP path health check ─────────────────────────────────────────────────────

_VIDEO_EXTS = {".avi", ".mp4", ".mov", ".h264", ".mkv", ".m4v"}

# Map keywords in old paths to preferred video subdirectory names (most specific first)
_DIR_HINTS = [
    ("NO_Colormap",  "PROCESSED_NO_Colormap_Videos"),
    ("Colormap",     "PROCESSED_Colormap_Videos"),
    ("RAW",          "RAW_Videos"),
    ("NOVA",         "PROCESSED_NOVA_Wrong_Res_Videos"),
]


def _extract_video_paths_from_slp(slp: Path) -> list[str]:
    """Read active video paths from a .slp file using h5py (not raw bytes).

    Reads the live dataset values only — orphaned HDF5 heap data (left over
    from previous writes) is ignored automatically.  Falls back to raw-bytes
    regex if h5py is unavailable.
    """
    import json as _json
    paths: list[str] = []

    try:
        import h5py
        with h5py.File(str(slp), "r") as f:
            # videos_json: shape=(N,) object array of JSON bytes
            if "videos_json" in f:
                for item in f["videos_json"][()].flat:
                    if isinstance(item, (bytes, bytearray)):
                        item = item.decode("utf-8", "replace")
                    try:
                        data = _json.loads(item)
                    except Exception:
                        continue
                    # Collect all string values under "filename" keys recursively
                    def _collect(obj):
                        if isinstance(obj, dict):
                            for k, v in obj.items():
                                if k == "filename" and isinstance(v, str):
                                    paths.append(v)
                                else:
                                    _collect(v)
                        elif isinstance(obj, list):
                            for v in obj:
                                _collect(v)
                    _collect(data)
        return paths
    except ImportError:
        pass

    # Fallback: raw bytes (may include orphaned heap data, but better than nothing)
    raw = slp.read_bytes()
    return [
        m.decode("utf-8", "replace")
        for m in _re.findall(rb'"filename":"([^"]+)"', raw)
    ]


def scan_slp_paths(nb_dir: Path, root_dir: Path | None = None) -> list[dict]:
    """Scan ALL .slp files (not .pkg.slp) in the project for broken video paths.

    Reads only active dataset values via h5py — orphaned HDF5 heap data from
    previous writes is never reported as broken.

    Four categories are scanned:
      dataset     – Inference_Pipeline/SLEAP_Dataset/
      models      – Inference_Pipeline/Models/SLEAP_Models/**/labels_*.slp
      predictions – Inference_Pipeline/Predictions/
      training    – SLEAP_Training/  (only when root_dir is supplied)

    Each result dict contains:
      slp           – Path to the .slp file
      category      – 'dataset' | 'models' | 'predictions' | 'training'
      paths_ok      – video paths that exist on disk
      paths_broken  – video paths that do NOT exist on disk
      paths_fixable – {raw_broken_str: new_Path} for auto-resolvable broken paths
      all_ok        – True when no broken paths
      all_fixable   – True when every broken path has a found replacement
    """
    # ── Video lookup: {dir_name: {lower_filename: Path}} ──────────────────────
    vid_dirs: dict[str, dict[str, Path]] = {}
    for vd in [
        nb_dir / "Videos" / "PROCESSED_Colormap_Videos",
        nb_dir / "Videos" / "PROCESSED_NO_Colormap_Videos",
        nb_dir / "Videos" / "RAW_Videos",
        nb_dir / "Videos" / "PROCESSED_NOVA_Wrong_Res_Videos",
    ]:
        if vd.exists():
            vid_dirs[vd.name] = {f.name.lower(): f for f in vd.glob("*.avi")}

    def _best_match(norm_path: str) -> Path | None:
        name = Path(norm_path).name.lower()
        for keyword, dir_name in _DIR_HINTS:
            if keyword.lower() in norm_path.lower() and dir_name in vid_dirs:
                if name in vid_dirs[dir_name]:
                    return vid_dirs[dir_name][name]
        for d in vid_dirs.values():
            if name in d:
                return d[name]
        return None

    # ── Candidate collection by category ──────────────────────────────────────
    _pkg = lambda f: ".pkg." in f.name
    _pre = lambda f: ".pre_trim." in f.name

    category_sources: list[tuple[str, list[Path]]] = []

    ds_dir = nb_dir / "SLEAP_Dataset"
    if ds_dir.exists():
        category_sources.append(("dataset", sorted(
            f for f in ds_dir.glob("*.slp") if not _pkg(f)
        )))

    models_dir = nb_dir / "Models" / "SLEAP_Models"
    if models_dir.exists():
        category_sources.append(("models", sorted(
            f for f in models_dir.rglob("labels_*.slp") if not _pkg(f)
        )))

    pred_dir = nb_dir / "Predictions"
    if pred_dir.exists():
        category_sources.append(("predictions", sorted(
            f for f in pred_dir.rglob("*.slp") if not _pkg(f) and not _pre(f)
        )))

    if root_dir is not None:
        train_dir = root_dir / "SLEAP_Training"
        if train_dir.exists():
            category_sources.append(("training", sorted(
                f for f in train_dir.glob("*.slp") if not _pkg(f)
            )))

    # ── Scan each file ─────────────────────────────────────────────────────────
    results = []
    for category, candidates in category_sources:
        for slp in candidates:
            try:
                raw_paths = _extract_video_paths_from_slp(slp)
            except Exception:
                continue

            seen, ok, broken, fixable = set(), [], [], {}
            for p in raw_paths:
                norm = p.replace("\\\\", "/").replace("\\", "/")
                if Path(norm).suffix.lower() not in _VIDEO_EXTS:
                    continue
                if norm in seen:
                    continue
                seen.add(norm)
                if Path(norm).exists():
                    ok.append(norm)
                else:
                    broken.append(norm)
                    match = _best_match(norm)
                    if match:
                        fixable[p] = match

            results.append({
                "slp":           slp,
                "category":      category,
                "paths_ok":      ok,
                "paths_broken":  broken,
                "paths_fixable": fixable,
                "all_ok":        not broken,
                "all_fixable":   bool(broken) and len(fixable) == len(broken),
            })
    return results


def fix_slp_paths(slp_path: Path, replacements: dict) -> tuple[bool, str]:
    """Update broken video paths embedded in a .slp HDF5 file.

    replacements: {old_raw_path_str -> new_Path}
    Returns (success, message).

    Targets the videos_json dataset directly using JSON parsing (robust to
    any internal path format / slash style).  Three write strategies are tried
    in order: bulk assignment, element-wise, delete-and-recreate.
    """
    import json as _json

    # Build normalised replacement map: forward-slash key -> forward-slash new path
    repl_map: dict[str, str] = {}
    for old_str, new_path in replacements.items():
        new_s = str(new_path).replace("\\", "/")
        for variant in [old_str,
                        old_str.replace("/", "\\"),
                        old_str.replace("/", "\\\\")]:
            repl_map[variant.replace("\\\\", "/").replace("\\", "/")] = new_s

    def _fix_path(v: str) -> str:
        norm = v.replace("\\\\", "/").replace("\\", "/")
        return repl_map.get(norm, v)

    def _patch_blob(blob) -> tuple[object, bool]:
        """Parse one JSON blob, fix all filename fields, re-serialise."""
        is_bytes = isinstance(blob, (bytes, bytearray))
        s = blob.decode("utf-8", "replace") if is_bytes else str(blob)
        try:
            data = _json.loads(s)
        except Exception:
            return blob, False
        orig = _json.dumps(data, ensure_ascii=False, separators=(",", ":"))

        def _walk(obj):
            if isinstance(obj, dict):
                return {k: (_fix_path(v) if k == "filename" and isinstance(v, str)
                            else _walk(v))
                        for k, v in obj.items()}
            if isinstance(obj, list):
                return [_walk(v) for v in obj]
            return obj

        fixed = _walk(data)
        new_s = _json.dumps(fixed, ensure_ascii=False, separators=(",", ":"))
        if new_s == orig:
            return blob, False
        return (new_s.encode("utf-8") if is_bytes else new_s), True

    try:
        import h5py
        import numpy as np

        with h5py.File(str(slp_path), "r+") as f:
            if "videos_json" not in f:
                return False, "videos_json dataset not found in this file"

            ds  = f["videos_json"]
            raw = ds[()]

            # Normalise to list of blobs regardless of dtype/shape
            blobs = [raw.flat[i] for i in range(raw.size)] if isinstance(raw, np.ndarray) else [raw]

            new_blobs, n_changed = [], 0
            for blob in blobs:
                new_blob, changed = _patch_blob(blob)
                new_blobs.append(new_blob)
                if changed:
                    n_changed += 1

            if n_changed == 0:
                return False, (
                    "paths not found inside videos_json — "
                    "the stored path string does not match any replacement key"
                )

            # ── Write-back: three strategies, first success wins ───────────────
            wrote = False

            # Strategy 1: bulk assignment into existing dataset
            if not wrote:
                try:
                    if isinstance(raw, np.ndarray):
                        new_arr = np.empty(raw.shape, dtype=raw.dtype)
                        for i, v in enumerate(new_blobs):
                            new_arr.flat[i] = v
                        ds[()] = new_arr
                    else:
                        ds[()] = new_blobs[0]
                    wrote = True
                except Exception:
                    pass

            # Strategy 2: element-wise assignment
            if not wrote:
                try:
                    for i, v in enumerate(new_blobs):
                        ds[i] = v
                    wrote = True
                except Exception:
                    pass

            # Strategy 3: delete dataset and recreate with string dtype
            if not wrote:
                try:
                    try:
                        dt = h5py.string_dtype()        # h5py >= 3
                    except AttributeError:
                        dt = h5py.special_dtype(vlen=bytes)  # h5py < 3
                    del f["videos_json"]
                    f.create_dataset("videos_json", data=new_blobs, dtype=dt)
                    wrote = True
                except Exception as e:
                    return False, f"all write strategies failed: {e}"

        return True, f"Updated {n_changed} video reference(s)"

    except ImportError:
        return False, "h5py not installed — run: pip install h5py"
    except Exception as e:
        return False, f"h5py error: {e}"
