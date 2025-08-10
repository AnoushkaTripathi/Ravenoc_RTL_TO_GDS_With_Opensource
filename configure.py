#!/usr/bin/env python3
import requests
import argparse
import os
import yaml
import logging
import sys
import csv
import re
import glob


def load_yaml(yaml_file):
    with open(yaml_file, "r") as stream:
        return yaml.safe_load(stream)


def write_user_config(module_name, sources):
    filename = 'user_config.tcl'
    os.makedirs('src', exist_ok=True)
    with open(os.path.join('src', filename), 'w') as fh:
        fh.write(f"set ::env(DESIGN_NAME) {module_name}\n")
        fh.write('set ::env(VERILOG_FILES) "\\\n')
        for line, source in enumerate(sources):
            fh.write(f"    $::env(DESIGN_DIR)/{source}")
            if line != len(sources) - 1:
                fh.write(' \\\n')
        fh.write('"\n')


def find_all_hdl_files():
    """Find all .v and .sv files in current directory recursively."""
    files = glob.glob("**/*.v", recursive=True) + glob.glob("**/*.sv", recursive=True)
    return sorted(files)


def get_project_source(yaml_cfg):
    try:
        wokwi_id = int(yaml_cfg['project'].get('wokwi_id', 0))
    except ValueError:
        logging.error("wokwi_id must be an integer")
        exit(1)

    # If project is from Wokwi
    if wokwi_id != 0:
        url = f"https://wokwi.com/api/projects/{wokwi_id}/verilog"
        logging.info(f"Downloading Verilog from {url}")
        r = requests.get(url)
        if r.status_code != 200:
            logging.error(f"Failed to download from {url}")
            exit(1)

        filename = f"user_module_{wokwi_id}.v"
        os.makedirs('src', exist_ok=True)
        with open(os.path.join('src', filename), 'wb') as fh:
            fh.write(r.content)

        # Also include all local HDL files
        local_files = find_all_hdl_files()
        return [filename] + local_files

    # No Wokwi ID — use source_files or autodetect
    source_files = yaml_cfg['project'].get('source_files', [])
    if not source_files:
        logging.info("No source_files in YAML, auto-detecting all HDL files...")
        source_files = find_all_hdl_files()

    if not source_files:
        logging.error("No HDL source files found!")
        exit(1)

    return source_files


def check_docs(yaml_cfg):
    for key in ['author', 'title', 'description', 'how_it_works', 'how_to_test', 'language']:
        if key not in yaml_cfg['documentation']:
            logging.error(f"Missing key {key} in documentation")
            exit(1)
        if yaml_cfg['documentation'][key] == "":
            logging.error(f"Missing value for {key} in documentation")
            exit(1)


def get_top_module(yaml_cfg):
    wokwi_id = int(yaml_cfg['project'].get('wokwi_id', 0))
    if wokwi_id != 0:
        return f"user_module_{wokwi_id}"
    else:
        return yaml_cfg['project']['top_module']


def get_stats():
    cells = 0
    area_file = 'runs/wokwi/reports/synthesis/1-synthesis.AREA 0.stat.rpt'
    metrics_file = 'runs/wokwi/reports/metrics.csv'

    if os.path.exists(area_file):
        with open(area_file) as f:
            for line in f.readlines():
                m = re.search(r'Number of cells:\s+(\d+)', line)
                if m:
                    print(line.strip())
                    cells = m.group(1)

    if os.path.exists(metrics_file):
        with open(metrics_file) as f:
            report = list(csv.DictReader(f))[0]
            report['cell_count'] = cells  # Fix broken cell count
            keys = ['OpenDP_Util', 'cell_count', 'wire_length',
                    'AND', 'DFF', 'NAND', 'NOR', 'OR', 'XOR', 'XNOR', 'MUX']
            print(f'| {"|".join(keys)} |')
            print(f'| {"|".join(["-----"] * len(keys))} |')
            print(f'| {"|".join(report.get(k, "") for k in keys)} |')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="TT setup for ravenoc")

    parser.add_argument('--check-docs', help="Check YAML documentation section", action="store_true")
    parser.add_argument('--get-stats', help="Print stats from the run", action="store_true")
    parser.add_argument('--create-user-config', help="Create user_config.tcl", action="store_true")
    parser.add_argument('--debug', help="Enable debug logging", action="store_const",
                        dest="loglevel", const=logging.DEBUG, default=logging.INFO)
    parser.add_argument('--yaml', help="YAML file to load", default='info.yaml')

    args = parser.parse_args()

    # Setup logging
    log_format = logging.Formatter('%(asctime)s - %(module)-10s - %(levelname)-8s - %(message)s')
    log = logging.getLogger('')
    log.setLevel(args.loglevel)
    ch = logging.StreamHandler(sys.stdout)
    ch.setFormatter(log_format)
    log.addHandler(ch)

    if args.get_stats:
        get_stats()

    elif args.check_docs:
        logging.info("Checking docs...")
        config = load_yaml(args.yaml)
        check_docs(config)

    elif args.create_user_config:
        logging.info("Creating include file...")
        config = load_yaml(args.yaml)
        source_files = get_project_source(config)
        top_module = get_top_module(config)
        write_user_config(top_module, source_files)

